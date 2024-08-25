//
//  PennySavedApp.swift
//  PennySaved
//
//  Created by Victor Saint Hilaire on 8/12/24.
//

import SwiftUI

@main
struct PennySavedApp: App {
    let persistenceController = PersistenceController.shared
    let goalsVm = GoalsVm.shared
    let savingsVm = SavingsVm.shared
    @State private var isLoading = true

    var body: some Scene {
        WindowGroup {
            if isLoading {
                LoadingAppView()
                    .onAppear {
                        setupCloudKitSyncObserver()
                    }
            } else {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(goalsVm)
                    .environmentObject(savingsVm)
                    .preferredColorScheme(.dark)
                    .tint(.white)
                    .onAppear {
                        CategoryManager.shared.fetchAndUpdateCategories(context: persistenceController.container.viewContext)
                    }
            }
        }
    }
    
    private func setupCloudKitSyncObserver() {
        // Listen for changes in Core Data that indicate a CloudKit sync
        NotificationCenter.default.addObserver(forName: .NSPersistentStoreRemoteChange, object: nil, queue: .main) { _ in
            // Handle the sync completion
            self.isLoading = false
        }

        // Optionally, you might want to add a timeout in case the sync takes too long.
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            if self.isLoading {
                self.isLoading = false // Hide loading view after timeout
            }
        }
    }
}
