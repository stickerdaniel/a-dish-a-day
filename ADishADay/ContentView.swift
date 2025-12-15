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
            // Calendar
            NavigationStack() {
                CalendarsView()
                    .tag(Tab.calendar)
            }
            .tabItem {
                Label("Calendars", systemImage: "calendar")
            }
            // Recipes
            NavigationStack() {
                RecipesView()
                    .tag(Tab.recipe)
            }
            .tabItem {
                Label("Recipes", systemImage: "book.pages")
            }
        }
        .environment(\.horizontalSizeClass, .compact) // 👈 Use this modifier to change to old navbar style
        // Padding 16 bottom only on MacOS not on iOS and iPadOS
        .padding(.bottom, bottomPadding)
    }
}

#Preview {
    ContentView()
}
