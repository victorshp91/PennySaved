//
//  Persistence.swift
//  PennySaved
//
//  Created by Victor Saint Hilaire on 8/12/24.
//

import CoreData

import CoreData

import SwiftUI
import CloudKit


class PersistenceController {
    
    static let shared = PersistenceController()
    
    let container: NSPersistentCloudKitContainer
    
    
    init() {
        container = NSPersistentCloudKitContainer(name: "PennySaved")
        
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("No persistent store descriptions found")
        }
        
        // Set CloudKit container options
        let cloudKitOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.PennySaved")
        description.cloudKitContainerOptions = cloudKitOptions
        
        // Enable remote change notifications
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        // Enable history tracking and automatic migration
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSMigratePersistentStoresAutomaticallyOption)
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                // Handle the error appropriately
                print("Unresolved error \(error), \(error.userInfo)")
                // Consider showing a user-friendly error message and handling recovery
            } else {
                // Successfully loaded the store
                print("Successfully loaded store: \(storeDescription)")
            }
        }
        
        container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        // Observe remote change notifications
        NotificationCenter.default.addObserver(self, selector: #selector(handleRemoteChange(_:)), name: .NSPersistentStoreRemoteChange, object: container.persistentStoreCoordinator)
    }
    
    @objc func handleRemoteChange(_ notification: Notification) {
        print("Received remote change notification")
        // Implement your logic to handle remote changes, such as fetching updates from CloudKit
    }
    
    func save() {
            let context = container.viewContext
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
}
