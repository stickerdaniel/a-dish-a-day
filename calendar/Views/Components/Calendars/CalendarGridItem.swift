//
//  CalendarGridItem.swift
//  calendar
//
//  Created by Daniel Sticker on 14.01.25.
//

import SwiftUI

struct CalendarGridItem: View {
    var calendar: CalendarModel
    var onSwitchToCreatedTab: (() -> Void)? // Callback to notify parent
    @State private var showDeleteConfirmation = false // Controls delete confirmation visibility
    @State private var navigateToEditView = false // Controls navigation to the edit view
    @Environment(\.modelContext) private var context

    var body: some View {
        VStack {
            Card(
                image: calendar.thumbnailImage,
                description: calendar.name,
                fallbackSymbols: ["frying.pan.fill", "stove.fill", "fork.knife", "calendar"]
            )
        }
        .contextMenu {
            Button(action: exportCalendar) {
                Label("Export Calendar", systemImage: "square.and.arrow.up")
            }

            if calendar.source == .created {
                Button(action: editCalendar) {
                    Label("Edit", systemImage: "pencil")
                }
            }

            if calendar.source == .created {
                Button(action: duplicateCalendar) {
                    Label("Duplicate", systemImage: "doc.on.doc")
                }
            }

            if calendar.source == .imported {
                Button(action: copyToCreatedSection) {
                    Label("Copy to Created", systemImage: "folder.badge.plus")
                }
            }

            Divider()

            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .confirmationDialog(
            "Are you sure you want to delete this calendar?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                deleteCalendar()
            }
            Button("Cancel", role: .cancel) {}
        }
        .navigationDestination(isPresented: $navigateToEditView) {
            EditCalendarView(calendarToEdit: calendar)
        }
    }

    // MARK: - Context Menu Actions

    /// Handles exporting and sharing the calendar as JSON
    private func exportCalendar() {
        if let url = ExportManager.exportCalendar(calendar) {
            ExportManager.shareFile(url: url)
        }
    }

    /// Opens the edit view for the calendar
    private func editCalendar() {
        navigateToEditView = true
    }

    /// Duplicates the calendar and adds it to the "created" section
    private func duplicateCalendar() {
        let duplicatedCalendar = CalendarModel(
            name: "\(calendar.name) (Copy)",
            startDate: calendar.startDate,
            endDate: calendar.endDate,
            thumbnailData: calendar.thumbnailData,
            source: .created
        )
        context.insert(duplicatedCalendar)
    }

    /// Copies an imported calendar to the "created" section
    private func copyToCreatedSection() {
        let copiedCalendar = CalendarModel(
            name: "\(calendar.name) (Copied)",
            startDate: calendar.startDate,
            endDate: calendar.endDate,
            thumbnailData: calendar.thumbnailData,
            source: .created
        )
        context.insert(copiedCalendar)
        onSwitchToCreatedTab?() // Notify parent to switch tabs
    }

    /// Deletes the calendar from the persistence context
    private func deleteCalendar() {
        context.delete(calendar)
    }
}
