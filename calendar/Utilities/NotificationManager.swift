//
//  NotificationManager1.swift
//  calendar
//
//  Created by Lucy May Plassmann on 20.01.25.
//

import SwiftUI
import UserNotifications

class NotificationManager: ObservableObject{
    //Singelton
    static let shared = NotificationManager()
    
    
    //request to send Notifications
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

    func scheduleNotifications(for calendarModel: CalendarModel) {
        let recipes = calendarModel.recipes
        let daysBetween = calendarModel.daysBetween

        guard daysBetween > 0 else {
            print("Invalid date range. StartDate must be earlier than EndDate.")
            return
        }

        for recipe in recipes {
            guard let unlockDate = recipe.unlockDate else {
                print("Recipe \(recipe.name) has no unlock date. Skipping.")
                continue
            }
            scheduleNotification(for: unlockDate, calendarName: calendarModel.name)
        }
    }

    func scheduleNotification(for date: Date, calendarName: String) {
        // Validate the date
        guard date >= Date() else {
            print("Notification date \(date) is in the past. Skipping.")
            return
        }

        // Content for the notification
        let content = UNMutableNotificationContent()
        content.title = "New door in Calendar: \(calendarName)"
        content.body = "You can open your new door."
        content.sound = .default

        // Set dynamic badge count
        UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
            content.badge = NSNumber(value: notifications.count + 1)
        }

        // Trigger
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        // Unique request identifier
        let request = UNNotificationRequest(identifier: calendarName + ", \(date)", content: content, trigger: trigger)

        // Add the notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled for \(date).")
            }
        }
    }


    func deleteNotification(for calendar : CalendarModel){
        //should delete all notifications for one calendar if a calendar is deleted
        
        let calendarName = calendar.name

            // Fetch pending notifications
            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                // Filter identifiers matching the calendar name
                let identifiersToRemove = requests
                    .filter { $0.identifier.starts(with: "\(calendarName),") }
                    .map { $0.identifier }
                
                // Remove matching pending notifications
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
            }
        
        // Fetch delivered notifications
            UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
                // Filter identifiers matching the calendar name
                let identifiersToRemove = notifications
                    .filter { $0.request.identifier.starts(with: "\(calendarName),") }
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

