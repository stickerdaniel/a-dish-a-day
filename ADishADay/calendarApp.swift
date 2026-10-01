//
//  calendarApp.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/16.
//

import SwiftUI

// Inject compiles to no-ops outside Debug, so every build configuration needs it.
// It loads the InjectionIII or InjectionNext bundle itself on first use.
@_exported import Inject

@main
struct CalendarApp: App {
  @AppStorage("appearance") private var appearance: Appearance = .system
  @StateObject private var authManager = AuthenticationManager.shared
  @State private var showLoginOnLaunch = false

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(authManager)
        .onAppear {
          applyAppearance()
          NotificationManager.requestAuthorization()
        }
        .task {
          // Initialize auth and determine if we should show login
          await authManager.initialize()

          // Show login on launch if not authenticated and no cached credentials
          if !authManager.authState.isAuthenticated && !authManager.hasCachedCredentials {
            showLoginOnLaunch = true
          }
        }
        .fullScreenCover(isPresented: $showLoginOnLaunch) {
          NavigationStack {
            LoginView()
              .environmentObject(authManager)
          }
        }
        .modelContainer(for: [
          RecipeModel.self,
          CalendarModel.self
        ])
    }
  }

  /// Apply saved appearance at app launch
  private func applyAppearance() {
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
      for window in windowScene.windows {
        switch appearance {
        case .light:
          window.overrideUserInterfaceStyle = .light
        case .dark:
          window.overrideUserInterfaceStyle = .dark
        case .system:
          window.overrideUserInterfaceStyle = .unspecified
        }
      }
    }
  }
}
