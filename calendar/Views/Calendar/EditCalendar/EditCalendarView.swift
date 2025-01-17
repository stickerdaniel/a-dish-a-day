//
//  EditCalendarView.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/18.
//

import SwiftUI
import SwiftData

struct EditCalendarView: View {
    /// If non-nil, we are editing an existing calendar. Otherwise we create a new one.
    var calendarToEdit: CalendarModel?

    @State private var editingCalendar: CalendarModel
    @State private var thumbnailImage: UIImage?

    // For showing the recipe picker sheet
    @State private var isPickingRecipe = false
    @State private var currentSelectedDate: Date? = nil

    /// Real recipes fetched via SwiftData
    @Query private var allRecipes: [RecipeModel]

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    // MARK: - Init
    init(calendarToEdit: CalendarModel? = nil) {
        self.calendarToEdit = calendarToEdit

        // If we have an existing calendar, clone it into editingCalendar.
        // Otherwise, create a brand new instance with default dates.
        _editingCalendar = State(initialValue:
            calendarToEdit ??
            CalendarModel(name: "", startDate: Date(), endDate: Date())
        )
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                // (1) Calendar Name
                Section(header: Text("Name")) {
                    TextField("Calendar Title", text: $editingCalendar.name)
                }

                // (2) Thumbnail Image
                Section(header: Text("Thumbnail Image")) {
                    PhotoPicker(title: "Select Image", selectedImage: $thumbnailImage)
                }

                // (3) Date Range
                Section(header: Text("Date Range")) {
                    // Start Date
                    DatePicker("Start Date", selection: $editingCalendar.startDate, displayedComponents: .date)

                    // End Date (limited so user can't pick before startDate)
                    DatePicker("End Date", selection: $editingCalendar.endDate, in: editingCalendar.startDate..., displayedComponents: .date)
                }

                // (4) Days in range
                if editingCalendar.startDate <= editingCalendar.endDate {
                    Section(header: Text("Days (\(editingCalendar.daysBetween))")) {
                        CardGridView(
                            items: editingCalendar.allDates,     // Must be Identifiable + Hashable
                            addButton: AnyView(EmptyView())
                        ) { date in
                            // Check if there's already a recipe for this day
                            let existingEntry = editingCalendar.recipes.first {
                                $0.date == date.midnight
                            }
                            let assignedRecipe = existingEntry?.recipe

                            // Use your custom day card
                            DayCard(
                                date: date,
                                recipeAssigned: assignedRecipe
                            ) {
                                // On tap, store the date and show the sheet to pick a recipe
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
                    // Disables button if name is empty or date range is invalid
                    .disabled(editingCalendar.name.isEmpty || editingCalendar.startDate > editingCalendar.endDate)
                }
            }
            .onAppear {
                loadCalendarData()
            }
            // (5) Show the new sheet when user taps a day
            .sheet(isPresented: $isPickingRecipe) {
                if let date = currentSelectedDate {
                    RecipeSelectionSheet(
                        isPresented: $isPickingRecipe,
                        recipes: allRecipes
                    ) { chosenRecipe in
                        assignRecipe(chosenRecipe, to: date)
                    }
                }
            }
        }
    }

    // MARK: - Actions

    /// Populates the `editingCalendar` fields from an existing calendar (if editing),
    /// and sets the local thumbnail image if it exists.
    private func loadCalendarData() {
        guard let existing = calendarToEdit else { return }
        editingCalendar.name = existing.name
        editingCalendar.startDate = existing.startDate
        editingCalendar.endDate = existing.endDate
        editingCalendar.recipes = existing.recipes
        editingCalendar.thumbnailData = existing.thumbnailData

        // Convert the calendar's existing thumbnailData to UIImage for display in PhotoPicker
        if let data = existing.thumbnailData,
           let loadedImage = UIImage(data: data) {
            thumbnailImage = loadedImage
        }
    }

    /// Inserts a new calendar or updates an existing one, then dismisses the view.
    private func saveCalendar() {
        // Update existing calendar or insert new
        if let existing = calendarToEdit {
            existing.name = editingCalendar.name
            existing.startDate = editingCalendar.startDate
            existing.endDate = editingCalendar.endDate
            existing.recipes = editingCalendar.recipes
            existing.thumbnailData = thumbnailImage?.jpegData(compressionQuality: 0.8)
        } else {
            editingCalendar.thumbnailData = thumbnailImage?.jpegData(compressionQuality: 0.8)
            context.insert(editingCalendar)
        }
        dismiss()
    }

    /// Assign or update the recipe for a particular date.
    private func assignRecipe(_ recipe: RecipeModel, to date: Date) {
        if let existingEntry = editingCalendar.recipes.first(where: { $0.date == date.midnight }) {
            existingEntry.recipe = recipe
        } else {
            let newEntry = RecipeEntry(date: date.midnight, recipe: recipe)
            editingCalendar.recipes.append(newEntry)
        }
    }
}
