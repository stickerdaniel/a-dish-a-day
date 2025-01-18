//
//  EditCalendarView.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/18.
//

import SwiftUI
import SwiftData

struct EditCalendarView: View {
    /// The calendar being edited. If `nil`, a new calendar is created.
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

        // Use the existing calendar or create a new one
        _editingCalendar = State(initialValue:
            calendarToEdit?.copy() ?? CalendarModel(name: "", startDate: Date(), endDate: Date())
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
                    DatePicker("Start Date", selection: $editingCalendar.startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $editingCalendar.endDate, in: editingCalendar.startDate..., displayedComponents: .date)
                }

                // (4) Days in Range
                Section(header: Text("Days (\(editingCalendar.daysBetween))")) {
                    let columns = [GridItem(.adaptive(minimum: Card.minimumWidth), spacing: Card.spacing)]

                    LazyVGrid(columns: columns, spacing: Card.spacing) {
                        ForEach(editingCalendar.allDates, id: \.self) { date in
                            let assignedRecipe = editingCalendar.recipes.first(where: { $0.date == date.midnight })?.recipe

                            DayCard(date: date, recipeAssigned: assignedRecipe) {
                                currentSelectedDate = date
                                isPickingRecipe = true
                            }
                        }
                    }
                    .padding(.top, 8)
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
                    .disabled(editingCalendar.name.isEmpty || editingCalendar.startDate > editingCalendar.endDate)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear(perform: loadCalendarData)
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

    /// Load data from the existing calendar if editing, and initialize the thumbnail.
    private func loadCalendarData() {
        guard let existing = calendarToEdit else { return }

        editingCalendar.name = existing.name
        editingCalendar.startDate = existing.startDate
        editingCalendar.endDate = existing.endDate
        editingCalendar.recipes = existing.recipes.map { $0.copy() } // Copy recipe entries
        editingCalendar.thumbnailData = existing.thumbnailData

        if let data = existing.thumbnailData, let image = UIImage(data: data) {
            thumbnailImage = image
        }
    }

    /// Save changes to the calendar, whether adding a new one or updating an existing one.
    private func saveCalendar() {
        if let existing = calendarToEdit {
            existing.name = editingCalendar.name
            existing.startDate = editingCalendar.startDate
            existing.endDate = editingCalendar.endDate
            existing.recipes = editingCalendar.recipes.map { $0.copy() } // Deep copy recipes
            existing.thumbnailData = thumbnailImage?.jpegData(compressionQuality: 0.8)
        } else {
            editingCalendar.thumbnailData = thumbnailImage?.jpegData(compressionQuality: 0.8)
            context.insert(editingCalendar)
        }
        dismiss()
    }

    /// Assign a recipe to a specific date.
    private func assignRecipe(_ recipe: RecipeModel, to date: Date) {
        if let index = editingCalendar.recipes.firstIndex(where: { $0.date == date.midnight }) {
            editingCalendar.recipes[index].recipe = recipe
        } else {
            let newEntry = RecipeEntry(date: date.midnight, recipe: recipe)
            editingCalendar.recipes.append(newEntry)
        }
    }
}
