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
    case created = "My Calendars"
}

struct CalendarsView: View {
    @State private var isShowingSettings = false
    @State private var selection: CalendarTab = .imported
    @State private var isImportingJSON = false
    @State private var showReplaceAlert = false
    @Query private var allCalendars: [CalendarModel]
    @Environment(\.modelContext) private var context
    @AppStorage("hasImportedDefaultsOnce") private var hasImportedDefaultsOnce: Bool = false

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
                CalendarCard(calendar: calendar, selectedTab: $selection)
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
                allowedContentTypes: [.customcalendar],
                onCompletion: handleFileImport
            )
            .alert("Existing calendar was replaced.", isPresented: $showReplaceAlert) {
                Button("OK", role: .cancel) { }
            }
        }
        .onAppear {
            // Import default calendars only on the first launch
            if !hasImportedDefaultsOnce {
                CalendarImporter.importDefaultCalendars(
                    context: context
                )
                hasImportedDefaultsOnce = true
            }
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
            CalendarImporter.importCalendars(
                from: [url],
                context: context,
                existingCalendars: allCalendars,
                onReplace: {
                    showReplaceAlert = true
                }
            )
        case .failure(let error):
            print("Import failed: \(error.localizedDescription)")
        }
    }
}
