//
//  CategoriesManager.swift
//  PennySaved
//
//  Created by Victor Saint Hilaire on 8/13/24.
//

import CoreData
import Foundation

class CategoryManager {
    static let shared = CategoryManager()

    private init() {}

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
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()

        do {
            let existingCategories = try context.fetch(fetchRequest)
            var existingCategoriesDict = [String: Category]()
            
            for category in existingCategories {
                if let name = category.name {
                    existingCategoriesDict[name] = category
                }
            }

            for categoryData in categories {
                guard let name = categoryData["name"],
                      let icon = categoryData["icon"],
                      let color = categoryData["color"] else {
                          print("Invalid category data: \(categoryData)")
                          continue
                      }

                if let existingCategory = existingCategoriesDict[name] {
                    // Check if any attributes are different
                    var needsUpdate = false
                    
                    if existingCategory.icon != icon {
                        existingCategory.icon = icon
                        needsUpdate = true
                    }
                    
                    if existingCategory.color != color {
                        existingCategory.color = color
                        needsUpdate = true
                    }
                    
                    if needsUpdate {
                        print("Updated category: \(name)")
                    }

                } else {
                    // Add a new category
                    let newCategory = Category(context: context)
                    newCategory.id = UUID()
                    newCategory.name = name
                    newCategory.icon = icon
                    newCategory.color = color
                    print("Added new category: \(name)")
                }
            }

            // Delete categories that are not in the new JSON
            let newCategoryNames = Set(categories.compactMap { $0["name"] })
            for existingCategory in existingCategories where !newCategoryNames.contains(existingCategory.name ?? "") {
                context.delete(existingCategory)
                print("Deleted category: \(existingCategory.name ?? "Unknown")")
            }

            try context.save()
            print("Categories successfully saved to CoreData.")
        } catch {
            print("Error saving to CoreData: \(error)")
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
}
