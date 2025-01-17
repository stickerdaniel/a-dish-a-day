//
//  AddCalendarView.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/18.
//

import SwiftUI

struct EditCalendarView: View {
    // Optional calendar to edit
    var calendarToEdit: CalendarModel?

    // State variables for calendar properties
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
                        .onChange(of: endDate) {
                            if endDate < startDate {
                                endDate = startDate // Prevent invalid date ranges
                            }
                        }
                }
            }
            .navigationTitle(calendarToEdit == nil ? "New Calendar" : "Edit Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: saveCalendar) {
                        HStack {
                            Text(calendarToEdit == nil ? "Add" : "Save")
                            Image(systemName: calendarToEdit == nil ? "plus" : "checkmark")
                        }
                    }
                    .disabled(name.isEmpty || startDate > endDate) // Validate input
                }
            }
            .onAppear {
                loadCalendarData() // Load data if editing
            }
        }
    }

    // MARK: - Actions

    /// Loads existing calendar data if available
    private func loadCalendarData() {
        guard let calendar = calendarToEdit else { return }
        name = calendar.name
        startDate = calendar.startDate
        endDate = calendar.endDate
        if let thumbnailData = calendar.thumbnailData {
            thumbnailImage = UIImage(data: thumbnailData)
        }
    }

    /// Saves the calendar, either by updating an existing one or creating a new one
    private func saveCalendar() {
        if let calendar = calendarToEdit {
            // Update existing calendar
            calendar.name = name
            calendar.startDate = startDate
            calendar.endDate = endDate
            calendar.thumbnailData = thumbnailImage?.jpegData(compressionQuality: 0.8)
        } else {
            // Create a new calendar
            let newCalendar = CalendarModel(
                name: name,
                startDate: startDate,
                endDate: endDate,
                thumbnailData: thumbnailImage?.jpegData(compressionQuality: 0.8),
                source: .created
            )
            context.insert(newCalendar)
        }

        // Dismiss the view after saving
        dismiss()
    }
}

