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
    @Query private var allCalendars: [CalendarModel]
    @Environment(\.modelContext) private var context

    var body: some View {
        NavigationStack {
            CardsView(
                items: filteredCalendars,
                addButton: AnyView(
                    NavigationLink(
                        destination: selection == .created ? EditCalendarView() : nil
                    ) {
                        Card(
                            icon: addButtonIcon,
                            description: addButtonText
                        )
                    }
                    .onTapGesture {
                        if selection == .imported {
                            isImportingJSON = true
                        }
                    }
                ),
                header: {
                    Picker("Select Calendar Tab", selection: $selection) {
                        ForEach(CalendarTab.allCases, id: \.self) { tab in
                            Text(tab.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                }
            ) { calendar in
                CalendarCard(calendar: calendar)
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
