//
//  NotificationManager1.swift
//  calendar
//
//  Created by Lucy May Plassmann on 20.01.25.
//

import SwiftUI
import UserNotifications

class NotificationManager: ObservableObject {
  // Singleton
  static let shared = NotificationManager()

  // request to send Notifications
  static func requestAuthorization() {
    let options: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(options: options) { _, _ in
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
    let triggerDate = Calendar.current.dateComponents(
      [.year, .month, .day, .hour, .minute, .second], from: date)
    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

    // Unique request identifier
    let request = UNNotificationRequest(
      identifier: calendar.id.uuidString + ", " + date.description, content: content,
      trigger: trigger)

    // Add the notification
    UNUserNotificationCenter.current().add(request) { _ in
    }
  }

  func deleteNotifications(for calendar: CalendarModel) {
    // set User Defaults to false
    UserDefaults.standard.set(false, forKey: "calendar_notifications_\(calendar.id)")

    let calendarID = calendar.id.uuidString

    // Fetch pending notifications
    UNUserNotificationCenter.current().getPendingNotificationRequests { requests in

      // Filter identifiers matching the calendar ID
      let identifiersToRemove =
        requests
        .filter { $0.identifier.starts(with: "\(calendarID),") }
        .map { $0.identifier }

      // Remove matching pending notifications
      UNUserNotificationCenter.current().removePendingNotificationRequests(
        withIdentifiers: identifiersToRemove)
    }

    // Fetch delivered notifications
    UNUserNotificationCenter.current().getDeliveredNotifications { notifications in

      // Filter identifiers matching the calendar ID
      let identifiersToRemove =
        notifications
        .filter { $0.request.identifier.starts(with: "\(calendarID),") }
        .map { $0.request.identifier }

      // Remove matching delivered notifications
      UNUserNotificationCenter.current().removeDeliveredNotifications(
        withIdentifiers: identifiersToRemove)
    }
  }

  func deleteAllNotifications() {
    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    UNUserNotificationCenter.current().removeAllDeliveredNotifications()
  }
}
