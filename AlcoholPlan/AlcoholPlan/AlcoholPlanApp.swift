//
//  AlcoholPlanApp.swift
//  AlcoholPlan
//
//  Created by 任挪亚 on 2026/4/10.
//

import SwiftUI
import CoreData

@main
struct AlcoholPlanApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
