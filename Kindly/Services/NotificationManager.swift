import Foundation
import UserNotifications
import SwiftUI

class NotificationManager: ObservableObject {
    @AppStorage("notificationsEnabled") var notificationsEnabled: Bool = true
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.notificationsEnabled = granted
                
                if granted {
                    self.scheduleNotification()
                }
                
                if let error = error {
                    print("Error requesting authorization for notifications: \(error)")
                }
            }
        }
    }
    
    func scheduleNotification() {
        guard notificationsEnabled else { return }
        
        // Remove any existing notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Set up notification content
        let content = UNMutableNotificationContent()
        content.title = "Today's Act of Kindness"
        content.body = "Open Kindly to see your daily kindness task."
        content.sound = .default
        
        // Set up time for 10 AM
        var dateComponents = DateComponents()
        dateComponents.hour = 10
        dateComponents.minute = 0
        
        // Create the trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Create the request
        let request = UNNotificationRequest(
            identifier: "dailyKindnessReminder",
            content: content,
            trigger: trigger
        )
        
        // Add the notification request
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    func toggleNotifications() {
        if notificationsEnabled {
            scheduleNotification()
        } else {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
    }
} 