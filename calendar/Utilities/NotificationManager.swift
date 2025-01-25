//
//  NotificationManager1.swift
//  calendar
//
//  Created by Lucy May Plassmann on 20.01.25.
//

import SwiftUI
import UserNotifications

class NotificationManager: ObservableObject{
    // Singelton
    static let shared = NotificationManager()
    
    
    // request to send Notifications
    static func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
            if let error = error {
                print("error \(error)")
            }else{
                print("Success")
            }
        }
    }

    // Schedule notifications for all recipes in the calendar
    func scheduleNotifications(for calendar: CalendarModel) {
        // Set default notification preference to true for this calendar
        UserDefaults.standard.set(true, forKey: "calendar_notifications_\(calendar.id)")
        
        // Schedule notifications for each recipe
        for recipe in calendar.recipes {
            if let unlockDate = recipe.unlockDate {
                scheduleNotification(for: unlockDate, calendar: calendar)
            }
        }
    }

    private func scheduleNotification(for date: Date, calendar: CalendarModel) {
        // Validate the date
        guard date >= Date() else {
            print("Notification date \(date) is in the past. Skipping.")
            return
        }

        // Content for the notification
        let content = UNMutableNotificationContent()
        content.title = "Open \(calendar.name)"
        content.body = "A new recipe is unlocked!"
        content.sound = .default

        // Set dynamic badge count
        UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
            content.badge = NSNumber(value: notifications.count + 1)
        }

        // Trigger
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        // Unique request identifier
        let request = UNNotificationRequest(identifier: calendar.id.uuidString + ", " + date.description, content: content, trigger: trigger)

        // Add the notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled for \(date).")
            }
        }
    }


    func deleteNotifications(for calendar : CalendarModel){
        // set User Defaults to false
        UserDefaults.standard.set(false, forKey: "calendar_notifications_\(calendar.id)")

        //should delete all notifications for one calendar if a calendar is deleted
        print("Deleting notifications for calendar: \(calendar.name)")
        let calendarID = calendar.id.uuidString

            // Fetch pending notifications
            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                // Print 
                print("Pending notifications: \(requests.count)")

                // Filter identifiers matching the calendar ID
                let identifiersToRemove = requests
                    .filter { $0.identifier.starts(with: "\(calendarID),") }
                    .map { $0.identifier }
                
                // Remove matching pending notifications
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
            }
        
            // Fetch delivered notifications
            UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
                // Print
                print("Delivered notifications: \(notifications.count)")

                // Filter identifiers matching the calendar ID
                let identifiersToRemove = notifications
                    .filter { $0.request.identifier.starts(with: "\(calendarID),") }
                    .map { $0.request.identifier }
                
                // Remove matching delivered notifications
                UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: identifiersToRemove)
            }
    }
    
    func deleteAllNotifications(){
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
}

