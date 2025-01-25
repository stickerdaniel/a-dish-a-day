//
//  CalendarImporter.swift
//  calendar
//
//  Created by Daniel Sticker on 25.01.25.
//

import Foundation
import SwiftUI
import SwiftData

struct CalendarImporter {
    static func importCalendars(
        from urls: [URL],
        existingCalendars: [CalendarModel],
        context: ModelContext,
        onReplace: @escaping () -> Void
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
                    context.delete(existing)
                    onReplace()
                }
                context.insert(calendar)
                NotificationManager.shared.scheduleNotifications(for: calendar)
            },
            onError: { error in
                print("Import failed: \(error.localizedDescription)")
            }
        )

        for url in urls {
            handler.process(.success(url))
        }
    }
}
