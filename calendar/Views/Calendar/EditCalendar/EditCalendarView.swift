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

        let initialCalendar: CalendarModel
        if let existingCalendar = calendarToEdit {
            initialCalendar = existingCalendar.copy() // Use the copy method
        } else {
            initialCalendar = CalendarModel(name: "", startDate: Date(), endDate: Date())
        }

        _editingCalendar = State(initialValue: initialCalendar)
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
                            let assignedRecipe = editingCalendar.recipes[date.midnight]

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
        editingCalendar.recipes = existing.recipes // Assign recipes directly
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
            existing.recipes = editingCalendar.recipes // Copy recipes correctly
            existing.thumbnailData = thumbnailImage?.jpegData(compressionQuality: 0.8)
        } else {
            editingCalendar.thumbnailData = thumbnailImage?.jpegData(compressionQuality: 0.8)
            context.insert(editingCalendar)
        }

        do {
            try context.save()
            dismiss()
        } catch {
            print("Saving error: \(error)")
        }
    }

    /// Assign a recipe to a specific date.
    private func assignRecipe(_ recipe: RecipeModel, to date: Date) {
        editingCalendar.assignRecipe(recipe, to: date)
    }
}
