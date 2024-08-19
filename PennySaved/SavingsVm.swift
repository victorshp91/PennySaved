//
//  SavingsVm.swift
//  PennySaved
//
//  Created by Victor Saint Hilaire on 8/17/24.
//

import Foundation
import CoreData
import SwiftUI

class SavingsVm: ObservableObject {
    
    private let viewContext: NSManagedObjectContext
    
    @Published var savings: [Saving] = []
    static let shared = SavingsVm(viewContext: PersistenceController.shared.container.viewContext)
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        fetchSavings()
        
    }
    func fetchSavings() {
        
        let request: NSFetchRequest<Saving> = Saving.fetchRequest()
       
        
        do {
            savings = try viewContext.fetch(request)
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

