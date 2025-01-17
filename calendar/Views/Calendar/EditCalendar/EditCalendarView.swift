//
//  EditCalendarView.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/18.
//

import SwiftUI
import SwiftData

struct EditCalendarView: View {
    @Binding var calendar: CalendarModel // Binding to the calendar being edited
    @State private var thumbnailImage: UIImage? // Local state for thumbnail

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                // (1) Calendar Name
                Section(header: Text("Name")) {
                    TextField("Calendar Title", text: $calendar.name)
                }

                // (2) Thumbnail Image
                Section(header: Text("Thumbnail Image")) {
                    PhotoPicker(title: "Select Image", selectedImage: $thumbnailImage)
                }

                // (3) Date Range
                Section(header: Text("Date Range")) {
                    DatePicker("Start Date", selection: $calendar.startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $calendar.endDate, in: calendar.startDate..., displayedComponents: .date)
                }

                // (4) Recipes for Days
                Section(header: Text("Days (\(calendar.daysBetween))")) {
                    let columns = [GridItem(.adaptive(minimum: Card.minimumWidth), spacing: Card.spacing)]

                    LazyVGrid(columns: columns, spacing: Card.spacing) {
                        ForEach(calendar.allDates, id: \.self) { date in
                            let assignedRecipe = calendar.recipes.first(where: { $0.date == date.midnight })?.recipe
                            DayCard(date: date, recipeAssigned: assignedRecipe) {
                                // Handle day card tap if needed
                            }
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Edit Calendar")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: saveCalendar) {
                        Text("Save")
                    }
                }
            }
            .onAppear {
                if let data = calendar.thumbnailData,
                   let uiImage = UIImage(data: data) {
                    thumbnailImage = uiImage
                }
            }
        }
    }

    private func saveCalendar() {
        calendar.thumbnailData = thumbnailImage?.jpegData(compressionQuality: 0.8)
        dismiss()
    }
}

