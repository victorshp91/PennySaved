//
//  CategoriesManager.swift
//  PennySaved
//
//  Created by Victor Saint Hilaire on 8/13/24.
//

import CoreData
import Foundation

class CategoryManager {
    static let shared = CategoryManager(viewContext: PersistenceController.shared.container.viewContext)
      private let viewContext: NSManagedObjectContext
      private let userDefaults = UserDefaults.standard
      private let lastFetchDateKey = "lastCategoryFetchDate"
      private let fetchIntervalInDays = 1 // Fetch new data every day

      init(viewContext: NSManagedObjectContext) {
          self.viewContext = viewContext
          if shouldFetchCategories() {
              fetchAndUpdateCategories(context: viewContext)
          }
      }

    private func shouldFetchCategories() -> Bool {
        if let lastFetchDate = userDefaults.object(forKey: lastFetchDateKey) as? Date {
            let daysSinceLastFetch = Calendar.current.dateComponents([.day], from: lastFetchDate, to: Date()).day ?? 0
            return daysSinceLastFetch >= fetchIntervalInDays
        }
        return true // Fetch if we've never fetched before
    }

    func fetchCategoriesFromURL(completion: @escaping ([[String: String]]?) -> Void) {
        guard let url = URL(string: "https://rayjewelry.us/savings/categories.json") else {
            print("Invalid URL")
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("No data received from the server")
                completion(nil)
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let categories = json["categories"] as? [[String: String]] {
                    completion(categories)
                } else {
                    print("Invalid JSON structure")
                    completion(nil)
                }
            } catch {
                print("Error decoding JSON: \(error)")
                completion(nil)
            }
        }.resume()
    }

    func saveCategoriesToCoreData(_ categories: [[String: String]], context: NSManagedObjectContext) {
        context.performAndWait {
            do {
                for categoryData in categories {
                    guard let name = categoryData["name"],
                          let icon = categoryData["icon"],
                          let color = categoryData["color"] else {
                        print("Invalid category data: \(categoryData)")
                        continue
                    }

                    // Try to fetch existing category
                    let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "name == %@", name)
                    let existingCategories = try context.fetch(fetchRequest)

                    let category: Category
                    if let existingCategory = existingCategories.first {
                        // Update existing category
                        category = existingCategory
                    } else {
                        // Create new category if it doesn't exist
                        category = Category(context: context)
                        category.name = name
                    }

                    // Update or set icon and color
                    category.icon = icon
                    category.color = color

                    print("Updated/Added category: \(name)")
                }

                // Delete categories that are not in the new data
                let allCategories = try context.fetch(Category.fetchRequest())
                let newCategoryNames = Set(categories.compactMap { $0["name"] })
                for existingCategory in allCategories {
                    if let name = existingCategory.name, !newCategoryNames.contains(name) {
                        context.delete(existingCategory)
                        print("Deleted category: \(name)")
                    }
                }

                try context.save()
                userDefaults.set(Date(), forKey: lastFetchDateKey)
                print("Categories successfully saved to CoreData.")
            } catch {
                print("Error saving to CoreData: \(error)")
            }
        }
    }


    func fetchAndUpdateCategories(context: NSManagedObjectContext) {
        fetchCategoriesFromURL { categories in
            guard let categories = categories else {
                print("No categories to save")
                return
            }
            DispatchQueue.main.async {
                self.saveCategoriesToCoreData(categories, context: context)
            }
        }
    }

    func getLocalCategories() -> [Category] {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        
        // Add a sort descriptor to order by name
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            print("Error fetching local categories: \(error)")
            return []
        }
    }


    func forceFetchCategories() {
        fetchAndUpdateCategories(context: viewContext)
    }
}
