//
//  NotificationManager.swift
//  Aufgabe5Aschenbrenner
//
//  Created by Simon Núñez Aschenbrenner on 24.06.21.
//  Adapted from https://learnappmaking.com/local-notifications-scheduling-swift/
//

import Foundation
import UserNotifications

class PeriodicNotificationManager: NSObject, ObservableObject
{
    var notification: PeriodicNotification?
    
    func schedule() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional:
                self.scheduleNotifications()
            case .notDetermined:
                self.requestAuthorization()
            default:
                break
            }
        }
    }
    
    func cancel() {
        notification = nil
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("Notifications cancelled")
    }

    private func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted == true && error == nil {
                self.scheduleNotifications()
            }
        }
    }
    
    private func scheduleNotifications() {

        if (notification != nil) {
            let content = UNMutableNotificationContent()
            content.title = notification!.title
            content.sound = .default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: notification!.interval, repeats: true)
            let request = UNNotificationRequest(identifier: notification!.id, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                guard error == nil else { return }
                print("Notification scheduled: \"\(self.notification!.title)\" every \(self.notification!.interval) minutes")
            }
        }
    }
    
}

struct PeriodicNotification
{
    static let defaultInterval: TimeInterval = 240
    var id: String
    var title: String
    var interval: TimeInterval
    
    init() {
        id = "PeriodicNotification"
        title = "Wie geht es dir gerade?"
        interval = PeriodicNotification.defaultInterval
    }
    
    init(interval newInterval: TimeInterval) {
        self.init()
        interval = newInterval
    }
}
