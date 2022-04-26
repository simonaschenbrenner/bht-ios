//
//  SettingsView.swift
//  Aufgabe5Aschenbrenner
//
//  Created by Simon Núñez Aschenbrenner on 24.06.21.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var periodicNotificationManager: PeriodicNotificationManager
    @State var selectedTimeInterval = 240
    
    var body: some View {
        VStack {
            if (selectedTimeInterval == 0) {
                Text("Erinnere mich nie").font(.title2)
            } else {
                Text("Erinnere mich alle").font(.title2)
            }
            Picker("", selection: $selectedTimeInterval) {
                Text("").tag(0)
                Text("60 Minuten").tag(60)
                Text("2 Stunden").tag(120)
                Text("3 Stunden").tag(180)
                Text("4 Stunden").tag(240)
                Text("6 Stunden").tag(360)
                Text("24 Stunden").tag(1440)
            }
            Text("an Tagebucheinträge").font(.title2)
        }
        .onAppear() {
            selectedTimeInterval = Int(periodicNotificationManager.notification?.interval ?? 0)
        }
        .onDisappear() {
            periodicNotificationManager.cancel()
            if(selectedTimeInterval != 0) {
                periodicNotificationManager.notification = PeriodicNotification(interval: TimeInterval(selectedTimeInterval))
                periodicNotificationManager.schedule()
            }
        }
        .navigationTitle(Text("Einstellungen"))
    }

}
