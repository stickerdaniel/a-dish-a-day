//
//  EditCalendarView.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/18.
//

import SwiftUI

enum CalendarTab: String, CaseIterable {
    case created = "Created"
    case imported = "Imported"
}


struct CalendarView: View {
    
    @State private var isShowingSettings = false;
    @State private var selection: CalendarTab = .created
    @Binding var path: NavigationPath
    
    var body: some View {
        VStack {
            Picker("Select Calendar Tab" ,selection: $selection) {
//
                ForEach(CalendarTab.allCases, id: \.self) {
                    Text($0.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
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

#Preview {
    @Previewable @State var p = NavigationPath()
    CalendarView(path: $p)
}
