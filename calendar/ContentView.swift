//
//  ContentView.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/16.
//

import SwiftUI

enum Tab: String, CaseIterable {
    case calendar = "Calendar"
    case recipe = "Recipe"
}

struct ContentView: View {
    
    @State private var selection: Tab = .calendar
    @State private var calendarPath: NavigationPath = NavigationPath()
    
    
    var body: some View {
        TabView(selection: $selection) {
            NavigationStack(path: $calendarPath) {
                CalendarView()
                    
                    .tag(Tab.calendar)
                
                    
            }
            .tabItem {
                Label("Calendars", systemImage: "calendar")
            }

            NavigationStack() {
                
                RecipeView()
                    .tag(Tab.recipe)
            }
            .tabItem {
                Label("Recipes", systemImage: "book.pages")
            }
        }
        .modelContainer(for: CalendarModel.self)
        .modelContainer(for: Recipe.self)
    }
}

#Preview {
    ContentView()
}
