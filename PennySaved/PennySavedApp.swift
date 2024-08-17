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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(goalsVm)  // Pass the GoalsVm as an environment object
                .preferredColorScheme(.dark)
                .tint(.white)
                .onAppear {
                                    CategoryManager.shared.fetchAndUpdateCategories(context: persistenceController.container.viewContext)
                                }
        }
    }
}
