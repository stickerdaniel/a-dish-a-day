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
                    isImportingJSON.toggle()
                }
                .sheet(isPresented: $isImportingJSON) {
                    ImportCalendarSheet(onImport: { calendar in
                        importedCalendars.append(calendar)
                    })
                }
            )
        )
    }
}

struct ImportCalendarSheet: View {
    let onImport: (CalendarModel) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingFilePicker = false

    var body: some View {
        VStack {
            Text("Select a JSON file to import a calendar")
                .font(.headline)
                .padding()

            Button("Choose File") {
                isShowingFilePicker = true
            }
            .fileImporter(
                isPresented: $isShowingFilePicker,
                allowedContentTypes: [.json]
            ) { result in
                switch result {
                case .success(let url):
                    if let calendar = CalendarSerialization.decodeCalendar(from: url) {
                        onImport(calendar)
                    } else {
                        print("Failed to decode calendar.")
                    }
                case .failure(let error):
                    print("File import failed: \(error.localizedDescription)")
                }
                dismiss()
            }
            .padding()
        }
    }
}
