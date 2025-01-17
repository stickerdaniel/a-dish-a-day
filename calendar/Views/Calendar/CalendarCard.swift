//
//  CalendarCard.swift
//  calendar
//
//  Created by Daniel Sticker on 14.01.25.
//

import SwiftUI

struct CalendarCard: View {
    var calendar: CalendarModel
    var onEdit: (() -> Void)? // Callback to handle edit action
    var onSwitchToCreatedTab: (() -> Void)? // Callback to notify parent
    @State private var showDeleteConfirmation = false
    @Environment(\.modelContext) private var context

    var body: some View {
        Card(
            image: calendar.thumbnailImage,
            description: calendar.name,
            fallbackSymbols: ["frying.pan.fill", "stove.fill", "fork.knife", "calendar"]
        )
        .contextMenu {
            Button(action: exportCalendar) {
                Label("Export Calendar", systemImage: "square.and.arrow.up")
            }

            if calendar.source == .created {
                Button(action: { onEdit?() }) {
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
    }

    // MARK: - Context Menu Actions

    private func exportCalendar() {
        if let url = ExportManager.exportCalendar(calendar) {
            ExportManager.shareFile(url: url)
        }
    }

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

    private func copyToCreatedSection() {
        let copiedCalendar = CalendarModel(
            name: "\(calendar.name) (Copied)",
            startDate: calendar.startDate,
            endDate: calendar.endDate,
            thumbnailData: calendar.thumbnailData,
            source: .created
        )
        context.insert(copiedCalendar)
        onSwitchToCreatedTab?()
    }

    private func deleteCalendar() {
        context.delete(calendar)
    }
}
