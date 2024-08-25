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
        setupCloudKitSyncObserver()
    }
    
    private func setupCloudKitSyncObserver() {
        // Observe Core Data's CloudKit sync notifications
        NotificationCenter.default.addObserver(self, selector: #selector(cloudKitDataChanged), name: .NSPersistentStoreRemoteChange, object: nil)
        
        // Attempt to fetch data initially in case it's already available
        
        fetchGols()
    }
    
    @objc private func cloudKitDataChanged() {
        // Whenever CloudKit data changes, re-fetch the goals
        fetchGols()
    }
    
    func fetchGols() {
        let request: NSFetchRequest<Goals> = Goals.fetchRequest()
        
        // Sort the results by date in descending order
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            let fetchedGoals = try viewContext.fetch(request)
            
            // Ensure that updating the goals array happens on the main thread
            DispatchQueue.main.async {
                withAnimation {
                    self.goals = fetchedGoals
                }
            }
        } catch {
            print("Failed to fetch goals: \(error.localizedDescription)")
        }
    }
    
    // Function to sum the total amount of savings associated with a goal
    func totalSavings(for goal: Goals) -> Double {
        let savings = goal.saving?.allObjects as? [Saving]
        return savings?.reduce(0) { $0 + ($1.amount) } ?? 0
    }
}
