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
    case imported = "Imported"
    case created = "Created"
}

struct CalendarsView: View {
    @State private var isShowingSettings = false
    @State private var selection: CalendarTab = .created
    @State private var isImportingJSON = false
    @State private var selectedCalendar: CalendarModel? = nil

    @Query private var allCalendars: [CalendarModel]
    @Environment(\.modelContext) private var context

    var body: some View {
        NavigationStack {
            VStack {
                Picker("Select Calendar Tab", selection: $selection) {
                    ForEach(CalendarTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                CardsView(
                    items: filteredCalendars,
                    addButton: AnyView(
                        Card(
                            icon: addButtonIcon,
                            description: addButtonText
                        )
                        .onTapGesture {
                            handleAddOrImportAction()
                        }
                    )
                ) { calendar in
                    CalendarCard(
                        calendar: calendar,
                        onEdit: {
                            if calendar.source == .created {
                                selectedCalendar = calendar
                            }
                        },
                        onSwitchToCreatedTab: nil
                    )
                }
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
            .sheet(item: $selectedCalendar) { calendar in
                EditCalendarView(calendarToEdit: calendar)
            }
            .fileImporter(
                isPresented: $isImportingJSON,
                allowedContentTypes: [.json],
                onCompletion: handleFileImport
            )
        }
    }

    private var filteredCalendars: [CalendarModel] {
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

    private func handleAddOrImportAction() {
        if selection == .created {
            let newCalendar = CalendarModel(name: "", startDate: Date(), endDate: Date())
            context.insert(newCalendar)
            selectedCalendar = newCalendar
        } else {
            isImportingJSON = true
        }
    }

    private func handleFileImport(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            guard url.startAccessingSecurityScopedResource() else {
                print("Failed to access security-scoped resource.")
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }

            if let importedCalendar = CalendarSerialization.decodeCalendar(from: url) {
                importedCalendar.source = .imported
                context.insert(importedCalendar)
            } else {
                print("Failed to decode calendar.")
            }
        case .failure(let error):
            print("File import failed: \(error.localizedDescription)")
        }
    }
}
