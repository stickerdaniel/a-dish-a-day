//
//  AddCalendarView.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/18.
//

import SwiftUI

struct AddCalendarView: View {
    @State private var name = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var thumbnailImage: UIImage?

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                // Calendar Name Section
                Section(header: Text("Name")) {
                    TextField("Enter calendar name", text: $name)
                }

                // Upload Thumbnail Image Section
                Section(header: Text("Thumbnail Image")) {
                    PhotoPicker(
                        title: "Select Image",
                        selectedImage: $thumbnailImage
                    ).padding(.top, 4)
                }

                // Date Range Section
                Section(header: Text("Date Range")) {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                        .onChange(of: endDate) { newValue in
                            if newValue < startDate {
                                endDate = startDate // Prevent invalid date ranges
                            }
                        }
                }
            }
            .navigationTitle("New Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    // Add Button with "Create Calendar" Action
                    Button(action: addCalendar) {
                        HStack {
                            Text("Add")
                            Image(systemName: "plus")
                        }
                    }
                    .disabled(name.isEmpty || startDate > endDate) // Require valid name and date range
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: openHelp) {
                        Image(systemName: "questionmark.circle")
                    }
                }
            }
        }
    }

    // MARK: - Actions

    private func addCalendar() {
        let newCalendar = CalendarModel(
            name: name,
            startDate: startDate,
            endDate: endDate,
            thumbnailData: thumbnailImage?.jpegData(compressionQuality: 0.8) // Optional thumbnail
        )
        context.insert(newCalendar)
        dismiss()
    }

    private func openHelp() {
        // Placeholder for help action
        print("Help button tapped")
    }
}
