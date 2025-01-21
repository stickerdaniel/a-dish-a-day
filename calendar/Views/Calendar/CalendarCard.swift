//
//  CalendarCard.swift
//  calendar
//
//  Created by Daniel Sticker on 14.01.25.
//

import SwiftUI

struct CalendarCard: View {
    var calendar: CalendarModel
    @State private var showDeleteConfirmation = false
    @State private var showUnlockAlert = false  // State to control alert visibility
    @Environment(\.modelContext) private var context

    var body: some View {
        NavigationLink(destination: OpenCalendarView(calendar: calendar)) {
            Card(
                image: calendar.thumbnailImage,
                badgeType: calendar.hasNewUnlockedRecipes > 0 ? .indicator : .none,
                badgeNumber: calendar.hasNewUnlockedRecipes,
                description: calendar.name,
                fallbackSymbols: ["frying.pan.fill", "stove.fill", "fork.knife", "calendar"]
            )
        }
        .contextMenu {
            Button(action: exportCalendar) {
                Label("Export Calendar", systemImage: "square.and.arrow.up")
            }

            if calendar.source == .created {
                NavigationLink(destination: EditCalendarView(calendarToEdit: calendar)) {
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
                    Label("Copy to Created", systemImage: "square.and.arrow.down.on.square")
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
        .alert("All recipes must be unlocked to copy and edit this calendar.", isPresented: $showUnlockAlert) {
            Button("OK", role: .cancel) { }
        }
    }

    // MARK: - Context Menu Actions

    private func exportCalendar() {
        if let url = ExportManager.exportCalendar(calendar) {
            ExportManager.shareFile(url: url)
        }
    }

    private func duplicateCalendar() {
        let duplicatedCalendar = CalendarModel.copy(from: calendar, setName: calendar.name + " (copy)")
        context.insert(duplicatedCalendar)
    }

    private func copyToCreatedSection() {
        // check if all recipes are unlocked
        guard calendar.allRecipesUnlocked else {
            // #TODO show an alert "All recipes must be unlocked to copy and edit this calendar."
            showUnlockAlert = true
            return
        }
        
        let copiedCalendar = CalendarModel.copy(from: calendar, setName: calendar.name + " (imported copy)",
                                                setSource: CalendarSource.created)
        context.insert(copiedCalendar)
    }

    private func deleteCalendar() {
        context.delete(calendar)
    }
}
