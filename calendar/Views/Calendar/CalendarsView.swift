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
    var notificationManager = NotificationManager.shared
    @State private var isShowingSettings = false
    @State private var selection: CalendarTab = .imported
    @State private var isImportingJSON = false
    @State private var showReplaceAlert = false
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
        let handler = FileImportHandler<CalendarModel>(
            handleImport: { url in
                guard let calendar = CalendarSerialization.decodeCalendar(from: url) else {
                    throw URLError(.cannotDecodeContentData)
                }
                calendar.source = .imported
                return calendar
            },
            onSuccess: { calendar in
                if let existing = allCalendars.first(where: {
                    $0.id == calendar.id && $0.source == .imported
                }) {
                    context.delete(existing)
                    showReplaceAlert = true
                }
                context.insert(calendar)
                notificationManager.scheduleNotifications(for: calendar)
            },
            onError: { error in
                print("Import failed: \(error.localizedDescription)")
            }
        )
        
        handler.process(result)
    }
}
