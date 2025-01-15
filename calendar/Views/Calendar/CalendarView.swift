//
//  CalendarView.swift
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

struct CalendarView: View {
    @State private var isShowingSettings = false
    @State private var selection: CalendarTab = .imported

    // State for imported and created calendars
    @Query private var createdCalendars: [CalendarModel]
    @State private var importedCalendars: [CalendarModel] = []
    @State private var isImportingJSON = false
    @State private var isShowingForm = false

    var body: some View {
        CardGridView(
            items: selectedCalendars,
            addButton: AnyView(
                Card(
                    icon: addButtonIcon,
                    description: addButtonText
                )
                .onTapGesture {
                    handleAddAction()
                }
                .sheet(isPresented: $isShowingForm) {
                    AddCalendarView()
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
            CalendarGridItem(calendar: calendar)
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
    }

    // MARK: - Computed Properties

    private var selectedCalendars: [CalendarModel] {
        switch selection {
        case .imported:
            return importedCalendars.isEmpty ? CalendarModel.sampleCalendars : importedCalendars
        case .created:
            return createdCalendars
        }
    }

    private var addButtonIcon: Image {
        selection == .created
            ? Image(systemName: "plus")
            : Image(systemName: "tray.and.arrow.down")
    }

    private var addButtonText: String {
        selection == .created ? "Create new calendar" : "Import calendar"
    }

    // MARK: - Actions

    private func handleAddAction() {
        switch selection {
        case .imported:
            isImportingJSON = true
        case .created:
            isShowingForm = true
        }
    }

    private func handleFileImport(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            do {
                // Request access to the file's data (if security-scoped resource)
                guard url.startAccessingSecurityScopedResource() else {
                    print("Failed to access the security-scoped resource.")
                    return
                }
                defer { url.stopAccessingSecurityScopedResource() }
                
                // Decode calendar from the file
                if let calendar = CalendarSerialization.decodeCalendar(from: url) {
                    importedCalendars.append(calendar)
                } else {
                    print("Failed to decode calendar.")
                }
            } catch {
                print("Error handling file import: \(error.localizedDescription)")
            }
        case .failure(let error):
            print("File import failed: \(error.localizedDescription)")
        }
    }

}
