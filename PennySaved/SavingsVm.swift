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
          setupCloudKitSyncObserver()
      }
      
      private func setupCloudKitSyncObserver() {
          // Observe Core Data's CloudKit sync notifications
          NotificationCenter.default.addObserver(self, selector: #selector(cloudKitDataChanged), name: .NSPersistentStoreRemoteChange, object: nil)
          
          // Also attempt to fetch data initially in case it's already available
          fetchSavings()
      }
      
      @objc private func cloudKitDataChanged() {
          // Whenever CloudKit data changes, re-fetch the savings
          fetchSavings()
      }
    func fetchSavings() {
        let request: NSFetchRequest<Saving> = Saving.fetchRequest()
        
        // Añadir un descriptor de ordenamiento por fecha ascendente
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            let fetchedSavings = try viewContext.fetch(request)
                       
                       // Ensure that updating the savings array happens on the main thread
                       DispatchQueue.main.async {
                           withAnimation {
                               self.savings = fetchedSavings
                           }
                       }
        } catch {
            print("Failed to fetch savings: \(error.localizedDescription)")
        }
    }

    
    
    // Función para sumar el monto total de los savings asociados a un goal
        func totalSavings(for goal: Goals) -> Double {
            let savings = goal.saving?.allObjects as? [Saving]
            return savings?.reduce(0) { $0 + ($1.amount) } ?? 0
        }
}

