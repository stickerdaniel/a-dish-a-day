//
//  ImportedCalendarView.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/20.
//

import SwiftUI
import UniformTypeIdentifiers

struct ImportedCalendarView: View {
    @State private var importedCalendars: [CalendarModel] = []
    @State private var isImportingJSON = false

    var body: some View {
        CalendarGridView(
            calendars: importedCalendars,
            addButton: AnyView(
                CalendarCard(
                    icon: Image(systemName: "tray.and.arrow.down"),
                    description: "Import calendars"
                ) {
                    isImportingJSON = true // Trigger the file picker
                }
            )
        )
        .fileImporter(
            isPresented: $isImportingJSON,
            allowedContentTypes: [.json]
        ) { result in
            handleFileImport(result)
        }
    }

    private func handleFileImport(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            if let calendar = CalendarSerialization.decodeCalendar(from: url) {
                importedCalendars.append(calendar)
            } else {
                print("Failed to decode calendar.")
            }
        case .failure(let error):
            print("File import failed: \(error.localizedDescription)")
        }
    }
}
