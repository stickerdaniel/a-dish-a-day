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

    var numberOfDays: Int {
        let days = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
        return max(days + 1, 0) // Ensure non-negative number of days
    }

    var body: some View {
        NavigationStack {
            Form {
                // Calendar Name Section
                Section(header: Text("Name")) {
                    TextField("This time I'll finally learn to cook... 😤", text: $name)
                }

                // Upload Thumbnail Image Section
                Section(header: Text("Thumbnail Image")) {
                    PhotoPicker(
                        title: "Select Image",
                        selectedImage: $thumbnailImage
                    )
                    .padding(.top, 4)
                }

                // Date Range Section
                Section(header: Text("Date Range")) {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                        .onChange(of: endDate){
                            if endDate < startDate {
                                endDate = startDate // Prevent invalid date ranges
                            }
                        }
                }
            }
            .navigationTitle("New Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: addCalendar) {
                        HStack {
                            Text("Add")
                            Image(systemName: "plus")
                        }
                    }
                    .disabled(name.isEmpty || startDate > endDate) // Validate input
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

        // Dismiss the view after adding the calendar
        dismiss()
    }
}
