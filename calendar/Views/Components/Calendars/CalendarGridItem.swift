//
//  CalendarGridItem.swift
//  calendar
//
//  Created by Daniel Sticker on 14.01.25.
//

import SwiftUI

struct CalendarGridItem: View {
    var calendar: CalendarModel
    @State private var showErrorAlert = false // Controls error alert visibility

    var body: some View {
        NavigationLink(destination: EditCalendarView(calendar: calendar)) {
            Card(
                image: calendar.thumbnailImage, // Computed property to handle thumbnail
                description: calendar.name,
                fallbackSymbols: ["frying.pan.fill", "stove.fill", "fork.knife", "calendar"]
            )
        }
        .contextMenu {
            Button(action: exportCalendar) {
                Label("Export as JSON", systemImage: "square.and.arrow.up")
            }
        }
        .alert("Export Failed", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("We couldn't export your calendar. Please try again.")
        }
    }

    /// Handles the export and share logic
    private func exportCalendar() {
        if let url = ExportManager.exportCalendar(calendar) {
            ExportManager.shareFile(url: url) // Share the exported file
        } else {
            showErrorAlert = true // Show an error alert if encoding fails
        }
    }
}
