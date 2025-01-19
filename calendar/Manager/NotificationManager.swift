//
//  NotificationManager.swift
//  calendar
//
//  Created by Lucy May Plassmann on 19.01.25.
//

import SwiftUI
import UserNotifications

class NotificationManager: ObservableObject{
    static let shared = NotificationManager()
    
    
    //request to send Notifications
    static func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
            if let error = error {
                print("error \(error)")
            }else{
                print("Success")
                //var allCalendars: [CalendarModel]
                //for calendar in allCalendars{
                //    scheduleNotifications(for: calendar)
                //}
            }
        }
    }

    func scheduleNotifications(for calendarModel: CalendarModel) {
            let currentDate = Date()
            let calendar = Calendar.current
            
            // Calculate the days between startDate and endDate
            let daysBetween = calendarModel.daysBetween
            
            guard daysBetween > 0 else {
                print("Invalid date range. StartDate must be earlier than EndDate.")
                return
            }
            
            // Loop through all days in the range
            for dayOffset in 0..<daysBetween {
                if let notificationDate = calendar.date(byAdding: .day, value: dayOffset, to: calendarModel.startDate) {
                    if notificationDate >= currentDate {
                        print("SUCCESS")
                        scheduleNotification(for: notificationDate, calendarName: calendarModel.name)
                    }
                }
            }
        }

    func scheduleNotification(for date: Date, calendarName: String){
        //content to present in notification
        let content = UNMutableNotificationContent()
        content.title = "new door in Calendar: \(calendarName)"
        content.body = "you can open your new door"
        content.sound = .default
        content.badge = 1
        
        //trigger
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        //request
        let request = UNNotificationRequest(identifier: "newDoor", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    
}
