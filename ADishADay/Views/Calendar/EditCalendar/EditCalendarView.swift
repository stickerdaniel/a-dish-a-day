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

    @State private var editingCalendar = CalendarModel(
        name: "",
        startDate: Date().midnight,
        endDate: Date().addingTimeInterval(60 * 60 * 24 * 6).midnight
    )
    @State private var thumbnailImage: UIImage?

    // For showing the recipe picker sheet
    @State private var isPickingRecipe = false
    @State private var selectedDateForRecipePicker: Date? = nil
    
    // For import settings
    @State private var showingImportAlert: Bool = false

    /// Real recipes fetched via SwiftData
    @Query(sort: \RecipeModel.name) private var allRecipes: [RecipeModel]

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    // MARK: - Body
    var body: some View {
        Form {
            // (1) Calendar Name
            Section(header: Text("Name")) {
                TextField("Set a Calendar Title", text: $editingCalendar.name)
            }
            
            // (2) Thumbnail Image
            Section(header: Text("Thumbnail Image")) {
                PhotoPicker(title: "Select Image", selectedImage: $thumbnailImage)
            }
            
            // (3) Date Range
            Section(header: Text("Date Range")) {
                DatePicker("Start Date", selection: Binding(
                    get: { editingCalendar.startDate.midnight },
                    set: { editingCalendar.startDate = $0.midnight }
                ), displayedComponents: .date)
                
                DatePicker("End Date", selection: Binding(
                    get: { editingCalendar.endDate.midnight },
                    set: { editingCalendar.endDate = $0.midnight }
                ), in: editingCalendar.startDate..., displayedComponents: .date)
            }
            
            // (5) Days in Range
            Section(header: Text("Days (\(editingCalendar.daysBetween))")) {
                let columns = [GridItem(.adaptive(minimum: Card.minimumWidth), spacing: Card.spacing)]
                
                LazyVGrid(columns: columns, spacing: Card.spacing) {
                    ForEach(editingCalendar.allDates, id: \.self) { date in
                        // Fetch the assigned recipe for this date
                        let assignedRecipe = editingCalendar.getRecipe(for: date)
                        
                        DayCard(date: date, recipeAssigned: assignedRecipe) {
                            selectedDateForRecipePicker = date
                        }
                    }
                }
                .padding(.top, 8)
            }
            
            // (4) Import Settings
            Section(header: Text("Import Settings"), footer: Text("If enabled, the calendar's start date will be set to the import date. The end date and all recipe unlock dates will be adjusted accordingly.")) {
                Toggle("Adjust dates on import", isOn: $editingCalendar.adjustDatesOnImport)
                    .toggleStyle(SwitchToggleStyle())
                    .onChange(of: editingCalendar.adjustDatesOnImport) {
                        showingImportAlert = true
                    }
            }
        }
        .frame(maxWidth: .infinity)
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
        }
        .onAppear(perform: loadCalendarData)
        .sheet(isPresented: .init(
            get: { selectedDateForRecipePicker != nil },
            set: { if !$0 { selectedDateForRecipePicker = nil } }
        )) {
            if let date = selectedDateForRecipePicker {
                RecipeSelectionSheet(
                    isPresented: .init(
                        get: { selectedDateForRecipePicker != nil },
                        set: { if !$0 { selectedDateForRecipePicker = nil } }
                    ),
                    recipes: allRecipes
                ) { chosenRecipe in
                    assignRecipe(chosenRecipe, to: date)
                    selectedDateForRecipePicker = nil
                }
            }
        }
    }

    // MARK: - Actions
    private func loadCalendarData() {
        if let calendarToEdit = calendarToEdit {
            editingCalendar = CalendarModel.copy(from: calendarToEdit)
            if let data = calendarToEdit.thumbnailData {
                thumbnailImage = UIImage(data: data)
            }
        } else {
            editingCalendar = CalendarModel(
                name: "",
                startDate: Date().midnight,
                endDate: Date().addingTimeInterval(60 * 60 * 24 * 6).midnight
            )
            thumbnailImage = nil
        }
    }

    /// Save changes to the calendar, whether adding a new one or updating an existing one.
    private func saveCalendar() {
        if let existing = calendarToEdit {
            existing.name = editingCalendar.name
            existing.startDate = editingCalendar.startDate
            existing.endDate = editingCalendar.endDate
            existing.recipes = editingCalendar.recipes
            existing.thumbnailData = thumbnailImage?.jpegData(compressionQuality: 0.8)
            existing.adjustDatesOnImport = editingCalendar.adjustDatesOnImport
        } else {
            editingCalendar.thumbnailData = thumbnailImage?.jpegData(compressionQuality: 0.8)
            context.insert(editingCalendar)
        }

        do {
            try context.save()
            dismiss()
        } catch {
        }
    }

    /// Assign a recipe to a specific date.
    private func assignRecipe(_ recipe: RecipeModel, to date: Date) {
        // Remove any existing recipe assigned to the same date
        editingCalendar.recipes.removeAll { existingRecipe in
            guard let unlockDate = existingRecipe.unlockDate else { return false }
            return Calendar.current.isDate(unlockDate, inSameDayAs: date)
        }

        // Assign the new recipe with the specified unlock date
        editingCalendar.assignRecipe(recipe, unlockDate: date.midnight)
    }
}
