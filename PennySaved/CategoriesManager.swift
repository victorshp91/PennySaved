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
    private let maxFreeCategories = 6

    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        ensurePredefinedCategories()
    }

    // Categorías predefinidas
    private let predefinedCategories = [
        ["name": "Groceries", "icon": "cart.fill"],
        ["name": "Food", "icon": "fork.knife"],
        ["name": "Clothing", "icon": "tshirt.fill"],
        ["name": "Electronics", "icon": "iphone"],
        ["name": "Health Care", "icon": "bandage.fill"],
        ["name": "Transportation", "icon": "car.fill"]
    ]

    private func ensurePredefinedCategories() {
        viewContext.performAndWait {
            for categoryData in predefinedCategories {
                let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "name == %@", categoryData["name"] ?? "")
                
                do {
                    let existingCategories = try viewContext.fetch(fetchRequest)
                    if existingCategories.isEmpty {
                        let newCategory = Category(context: viewContext)
                        newCategory.name = categoryData["name"]
                        newCategory.icon = categoryData["icon"]
                        newCategory.isPredefined = true
                    }
                } catch {
                    print("Error checking for existing category: \(error)")
                }
            }
            
            do {
                try viewContext.save()
            } catch {
                print("Error saving predefined categories: \(error)")
            }
        }
    }

    func getLocalCategories() -> [Category] {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            print("Error fetching local categories: \(error)")
            return []
        }
    }

    func addCustomCategory(name: String, icon: String) {
        viewContext.performAndWait {
            let newCategory = Category(context: viewContext)
            newCategory.name = name
            newCategory.icon = icon
            newCategory.isPredefined = false
            
            do {
                try viewContext.save()
            } catch {
                print("Error saving custom category: \(error)")
            }
        }
    }

    func deleteCustomCategory(_ category: Category) {
        guard !category.isPredefined else { return }
        
        viewContext.delete(category)
        do {
            try viewContext.save()
        } catch {
            print("Error deleting custom category: \(error)")
        }
    }

    func canAddNewCategory() -> Bool {
        let customCategories = getLocalCategories().filter { !$0.isPredefined }
        return customCategories.count < maxFreeCategories
    }
}
