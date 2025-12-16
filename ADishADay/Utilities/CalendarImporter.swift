//
//  CalendarImporter.swift
//  calendar
//
//  Created by Daniel Sticker on 25.01.25.
//  This file handles the import of calendars (also default calendars)

import Foundation
import SwiftData
import SwiftUI

struct CalendarImporter {

  // Imports calendars from provided file URLs
  static func importCalendars(
    from urls: [URL],
    context: ModelContext,
    existingCalendars: [CalendarModel] = [],
    onReplace: (() -> Void)? = nil
  ) {
    let handler = FileImportHandler<CalendarModel>(
      handleImport: { url in
        guard let calendar = CalendarSerialization.decodeCalendar(from: url) else {
          throw URLError(.cannotDecodeContentData)
        }
        calendar.source = .imported
        return calendar
      },
      onSuccess: { calendar in
        if let existing = existingCalendars.first(where: {
          $0.id == calendar.id && $0.source == .imported
        }) {
          NotificationManager.shared.deleteNotifications(for: existing)
          context.delete(existing)
          onReplace?()  // Call only if provided
        }
        context.insert(calendar)
        NotificationManager.shared.scheduleNotifications(for: calendar)
      },
      onError: { _ in
      }
    )

    for url in urls {
      handler.process(.success(url))
    }
  }

  // Imports default calendars from the app bundle
  static func importDefaultCalendars(context: ModelContext) {
    guard let bundlePath = Bundle.main.resourcePath else {
      return
    }

    let bundleURL = URL(fileURLWithPath: bundlePath)
    let fileManager = FileManager.default

    do {
      // Get all `.ddcal` files in the bundle
      let fileURLs = try fileManager.contentsOfDirectory(
        at: bundleURL, includingPropertiesForKeys: nil
      )
      .filter { $0.pathExtension == "ddcal" }

      if fileURLs.isEmpty {
        return
      }

      importCalendars(
        from: fileURLs,
        context: context
      )
    } catch {
    }
  }
}
