//
//  CalendarsView.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/18.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

enum CalendarTab: String, CaseIterable {
    case imported = "Added"
    case created = "Created"
}

struct CalendarsView: View {
    @State private var isShowingSettings = false
    @State private var selection: CalendarTab = .imported
    @State private var isImportingJSON = false
    @State private var navigationPath = NavigationPath()
    @State private var selectedCalendarForEditing: CalendarModel? // State for calendar being edited

    @Query private var allCalendars: [CalendarModel]
    @Environment(\.modelContext) private var context

    var body: some View {
        NavigationStack(path: $navigationPath) {
            CardsView(
                items: selectedCalendars,
                addButton: AnyView(
                    Card(
                        icon: addButtonIcon,
                        description: addButtonText
                    )
                    .onTapGesture {
                        handleAddAction()
                    }
                    .fileImporter(
                        isPresented: $isImportingJSON,
                        allowedContentTypes: [.json],
                        onCompletion: handleFileImport
                    )
                ),
                header: {
                    Picker("Select Calendar Tab", selection: $selection) {
                        ForEach(CalendarTab.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 500)
                    .padding(.bottom)
                }
            ) { calendar in
                CalendarCard(
                    calendar: calendar,
                    onEdit: { editCalendar(calendar) }
                )
            }
            .navigationTitle("Calendars")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingSettings.toggle()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .sheet(isPresented: $isShowingSettings) {
                        SettingsView()
                    }
                }
            }
            .sheet(item: $selectedCalendarForEditing) { calendar in
                EditCalendarView(calendar: Binding(get: {
                    calendar
                }, set: { updatedCalendar in
                    updateCalendar(updatedCalendar)
                }))
            }
        }
    }

    private var selectedCalendars: [CalendarModel] {
        switch selection {
        case .imported:
            return allCalendars.filter { $0.source == .imported || $0.source == nil }
        case .created:
            return allCalendars.filter { $0.source == .created }
        }
    }

    private var addButtonIcon: Image {
        selection == .created ? Image(systemName: "plus") : Image(systemName: "tray.and.arrow.down")
    }

    private var addButtonText: String {
        selection == .created ? "Create new calendar" : "Import calendar"
    }

    private func handleAddAction() {
        if selection == .created {
            let newCalendar = CalendarModel(name: "", startDate: Date(), endDate: Date())
            context.insert(newCalendar)
            selectedCalendarForEditing = newCalendar
        } else {
            isImportingJSON = true
        }
    }

    private func editCalendar(_ calendar: CalendarModel) {
        selectedCalendarForEditing = calendar
    }

    private func updateCalendar(_ updatedCalendar: CalendarModel) {
        if let existingCalendar = allCalendars.first(where: { $0.id == updatedCalendar.id }) {
            existingCalendar.name = updatedCalendar.name
            existingCalendar.startDate = updatedCalendar.startDate
            existingCalendar.endDate = updatedCalendar.endDate
            existingCalendar.recipes = updatedCalendar.recipes
            existingCalendar.thumbnailData = updatedCalendar.thumbnailData

            // Save changes to the context
            try? context.save()
        }
    }


    private func handleFileImport(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            guard url.startAccessingSecurityScopedResource() else {
                print("Failed to access the security-scoped resource.")
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }

            if let calendar = CalendarSerialization.decodeCalendar(from: url) {
                calendar.source = .imported
                context.insert(calendar)
            } else {
                print("Failed to decode calendar.")
            }
        case .failure(let error):
            print("File import failed: \(error.localizedDescription)")
        }
    }
    
    struct BindingViewWrapper<Model: ObservableObject, Content: View>: View {
        @ObservedObject var model: Model
        let content: (Binding<Model>) -> Content

        init(model: Model, @ViewBuilder content: @escaping (Binding<Model>) -> Content) {
            self.model = model
            self.content = content
        }

        var body: some View {
            content(.constant(model))
        }
    }
}
