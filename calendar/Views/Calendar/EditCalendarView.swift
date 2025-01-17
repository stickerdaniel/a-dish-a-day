//
//  EditCalendarView.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/18.
//

import SwiftUI

struct EditCalendarView: View {
    // Optional calendar to edit
    var calendarToEdit: CalendarModel?

    @State private var editingCalendar: CalendarModel
    @State private var thumbnailImage: UIImage?

    // For showing the recipe picker sheet
    @State private var isPickingRecipe = false
    @State private var currentSelectedDate: Date? = nil

    // Example recipes; typically from SwiftData or a network fetch
    @State private var allRecipes: [RecipeModel] = [
        RecipeModel(name: "Pasta", ingredients: "...", steps: "..."),
        RecipeModel(name: "Pizza", ingredients: "...", steps: "..."),
        // ...
    ]

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    init(calendarToEdit: CalendarModel? = nil) {
        self.calendarToEdit = calendarToEdit
        _editingCalendar = State(initialValue:
            calendarToEdit ??
            CalendarModel(name: "", startDate: Date(), endDate: Date())
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                // 1) Calendar Name
                Section(header: Text("Name")) {
                    TextField("Calendar Title", text: $editingCalendar.name)
                }

                // 2) Thumbnail
                Section(header: Text("Thumbnail Image")) {
                    PhotoPicker(title: "Select Image", selectedImage: $thumbnailImage)
                }

                // 3) Date Range
                Section(header: Text("Date Range")) {
                    DatePicker("Start Date", selection: $editingCalendar.startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $editingCalendar.endDate, displayedComponents: .date)
                        .onChange(of: editingCalendar.endDate) { newEndDate in
                            if newEndDate < editingCalendar.startDate {
                                editingCalendar.endDate = editingCalendar.startDate
                            }
                        }
                }

                // 4) Days in range
                if editingCalendar.startDate <= editingCalendar.endDate {
                    Section(header: Text("Days (\(editingCalendar.daysBetween))")) {
                        // Because 'Date' must be Identifiable, we extended it above.
                        CardGridView(
                            items: editingCalendar.allDates,
                            addButton: AnyView(EmptyView())
                        ) { date in
                            // Is there an existing recipe entry for this day?
                            let existingEntry = editingCalendar.recipes.first {
                                $0.date == date.midnight
                            }
                            let assignedRecipe = existingEntry?.recipe

                            // Show each day as a card
                            DayCardView(
                                date: date,
                                recipeAssigned: assignedRecipe
                            ) {
                                // On tap, capture this date and show the sheet
                                currentSelectedDate = date
                                isPickingRecipe = true
                            }
                        }
                    }
                }
            }
            .navigationTitle(calendarToEdit == nil ? "New Calendar" : "Edit Calendar")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: saveCalendar) {
                        HStack {
                            Text(calendarToEdit == nil ? "Add" : "Save")
                            Image(systemName: calendarToEdit == nil ? "plus" : "checkmark")
                        }
                    }
                    .disabled(editingCalendar.name.isEmpty || editingCalendar.startDate > editingCalendar.endDate)
                }
            }
            .onAppear {
                loadCalendarData()
            }
            // 5) Show the new sheet
            .sheet(isPresented: $isPickingRecipe) {
                // Only present if we have a valid date
                if let date = currentSelectedDate {
                    RecipeSelectionSheet(
                        isPresented: $isPickingRecipe,
                        recipes: allRecipes
                    ) { chosen in
                        assignRecipe(chosen, to: date)
                    }
                }
            }
        }
    }

    // MARK: - Actions

    private func loadCalendarData() {
        guard let existing = calendarToEdit else { return }
        editingCalendar.name = existing.name
        editingCalendar.startDate = existing.startDate
        editingCalendar.endDate = existing.endDate
        editingCalendar.thumbnailData = existing.thumbnailData
        editingCalendar.recipes = existing.recipes
    }

    private func saveCalendar() {
        if let existing = calendarToEdit {
            // Update existing
            existing.name = editingCalendar.name
            existing.startDate = editingCalendar.startDate
            existing.endDate = editingCalendar.endDate
            existing.thumbnailData = thumbnailImage?.jpegData(compressionQuality: 0.8)
            existing.recipes = editingCalendar.recipes
        } else {
            // Insert new
            editingCalendar.thumbnailData = thumbnailImage?.jpegData(compressionQuality: 0.8)
            context.insert(editingCalendar)
        }
        dismiss()
    }

    /// Assign or update the recipe for a particular date
    private func assignRecipe(_ recipe: RecipeModel, to date: Date) {
        // If there's already an entry, update it
        if let existingEntry = editingCalendar.recipes.first(where: { $0.date == date.midnight }) {
            existingEntry.recipe = recipe
        } else {
            let newEntry = RecipeEntry(date: date.midnight, recipe: recipe)
            editingCalendar.recipes.append(newEntry)
        }
    }
}
