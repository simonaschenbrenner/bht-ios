//
//  Aufgabe5AschenbrennerApp.swift
//  Aufgabe5Aschenbrenner
//
//  Created by Simon Núñez Aschenbrenner on 16.06.21.
//

import SwiftUI

@main
struct Aufgabe5AschenbrennerApp: App {
    
    let persistenceController = PersistenceController.shared
    @StateObject var periodicNotificationManager = PeriodicNotificationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(periodicNotificationManager)
        }
    }
}
