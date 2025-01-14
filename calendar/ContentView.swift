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
    
    // Padding 16 bottom only on MacOS not on iOS and iPadOS
    var bottomPadding: CGFloat {
        #if os(iOS)
        return 0
        #else
        return 16
        #endif
    }
    
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
        .modelContainer(for: RecipeModel.self)
        .environment(\.horizontalSizeClass, .compact) // 👈 Use this modifier to change to
        // Padding 16 bottom only on MacOS not on iOS and iPadOS
        .padding(.bottom, bottomPadding)
    }
}

#Preview {
    ContentView()
}
