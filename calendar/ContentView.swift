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
            // Calendar
            NavigationStack(path: $calendarPath) {
                ScrollView {
                    ZigZagLineView(
                        views: [
                            Color.red.cornerRadius(25),
                            Color.green.cornerRadius(25),
                            Color.blue.cornerRadius(25),
                            Color.yellow.cornerRadius(25)
                        ]
                    )
                    .frame(height: 1000)
                }
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
