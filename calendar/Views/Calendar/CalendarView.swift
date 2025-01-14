//
//  EditCalendarView.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/18.
//

import SwiftUI

enum CalendarTab: String, CaseIterable {
    case imported = "Added"
    case created = "Created"
}


struct CalendarView: View {
    
    @State private var isShowingSettings = false;
    @State private var selection: CalendarTab = .imported
    
    var body: some View {
        VStack {
            Picker("Select Calendar Tab" ,selection: $selection) {
                ForEach(CalendarTab.allCases, id: \.self) {
                    Text($0.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            // max width
            .frame(maxWidth: 500)
            
            if selection == .created {
                CreatedCalendarView()
            } else {
                ImportedCalendarView()
            }
            Spacer()

        }
    
        .navigationTitle("Calendars")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Settings", systemImage: "gearshape") {
                    isShowingSettings.toggle()
                }
                .sheet(isPresented: $isShowingSettings) {
                    SettingsView()
                }
                .presentationDragIndicator(.visible)
            }
        }
    }
}

