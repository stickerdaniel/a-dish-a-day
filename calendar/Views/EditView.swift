//
//  EditView.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/18.
//

import SwiftUI

enum EditTab: String, CaseIterable {
    case calendar = "Calendar"
    case recipe = "Recipe"
}

struct EditView: View {
    
    @State private var selection: EditTab = .calendar
    
    var body: some View {
        TabView {
            EditCalendarView().tabItem {
                Text("Calendar")
            }
            EditRecipeView().tabItem {
                Text("Recipe")
            }
        }
//        Picker("Edit Tab" ,selection: $selection) {
//            
//            ForEach(EditTab.allCases, id: \.self) {
//                Text($0.rawValue)
//            }
//        }
//            .pickerStyle(.segmented)
//            .padding()
//        
//        VStack {
//            if selection == .calendar {
//                EditCalendarView()
//            } else {
//                EditRecipeView()
//            }
//        }
//        Spacer()
//        .toolbar {
//            ToolbarItem(placement: .topBarTrailing) {
//                NavigationLink(destination: SettingsView()) {
//                    Label("Settings", systemImage: "gearshape")
//                }
//            }
            
//        }
    }
}

#Preview {
    EditView()
}
