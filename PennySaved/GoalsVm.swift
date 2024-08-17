//
//  GoalsVm.swift
//  PennySaved
//
//  Created by Victor Saint Hilaire on 8/16/24.
//

import Foundation
import CoreData
import SwiftUI

class GoalsVm: ObservableObject {
    
    private let viewContext: NSManagedObjectContext
    
    @Published var goals: [Goals] = []
    static let shared = GoalsVm(viewContext: PersistenceController.shared.container.viewContext)
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        fetchGols()
        
    }
    func fetchGols() {
        
        let request: NSFetchRequest<Goals> = Goals.fetchRequest()
       
        
        do {
            goals = try viewContext.fetch(request)
        } catch {
            print("Failed to fetch decks: \(error.localizedDescription)")
        }
    }
    
    
    // Función para sumar el monto total de los savings asociados a un goal
        func totalSavings(for goal: Goals) -> Double {
            let savings = goal.saving?.allObjects as? [Saving]
            return savings?.reduce(0) { $0 + ($1.amount) } ?? 0
        }
}
