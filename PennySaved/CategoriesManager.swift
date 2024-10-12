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
        ["name": "Kids", "icon": "figure.child"],
        ["name": "Beauty", "icon": "paintbrush.fill"],
        ["name": "Fitness", "icon": "figure.walk"],
        ["name": "Automotive", "icon": "car.2.fill"],
        ["name": "Books", "icon": "book.closed.fill"],
        ["name": "Movies & TV", "icon": "tv.fill"],
        ["name": "Music", "icon": "music.note"],
        ["name": "Restaurants", "icon": "fork.knife.circle.fill"],
        ["name": "Coffee", "icon": "cup.and.saucer.fill"],
        ["name": "Bars & Nightlife", "icon": "wineglass.fill"],
        ["name": "Online Shopping", "icon": "globe"],
        ["name": "Charity", "icon": "hands.sparkles.fill"],
        ["name": "Gifts", "icon": "gift.fill"],
        ["name": "Pets", "icon": "pawprint.fill"],
        ["name": "Home Improvement", "icon": "hammer.fill"],
        ["name": "Garden", "icon": "leaf.fill"],
        ["name": "Cleaning", "icon": "trash.fill"],
        ["name": "Education", "icon": "graduationcap.fill"],
        ["name": "Office Supplies", "icon": "paperclip"],
        ["name": "Sporting Goods", "icon": "sportscourt.fill"],
        ["name": "Hobbies", "icon": "puzzlepiece.fill"],
        ["name": "Photography", "icon": "camera.fill"],
        ["name": "Technology", "icon": "cpu.fill"],
        ["name": "Crafts", "icon": "scissors"],
        ["name": "Games", "icon": "gamecontroller.fill"],
        ["name": "Luxury", "icon": "diamond.fill"],
        ["name": "Vacation", "icon": "airplane"]
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
}
