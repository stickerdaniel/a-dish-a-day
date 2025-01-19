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
    var notificationManager = NotificationManager.shared
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
                    Group {
                        if selection == .created {
                            NavigationLink(destination: EditCalendarView()) {
                                Card(
                                    icon: Image(systemName: "plus"),
                                    description: "Create new calendar"
                                )
                            }
                        } else if selection == .imported {
                            Card(
                                icon: Image(systemName: "tray.and.arrow.down"),
                                description: "Import calendar"
                            )
                            .onTapGesture {
                                isImportingJSON = true // Trigger the file import
                            }
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
                notificationManager.scheduleNotifications(for: importedCalendar)
            } else {
                print("Failed to decode calendar.")
            }
        case .failure(let error):
            print("File import failed: \(error.localizedDescription)")
        }
    }
}
