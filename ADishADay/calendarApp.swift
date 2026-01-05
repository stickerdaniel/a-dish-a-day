//
//  calendarApp.swift
//  calendar
//
//  Created by Vincent Nahn on 2024/12/16.
//

import SwiftUI

#if DEBUG
  @_exported import Inject
#endif

@main
struct CalendarApp: App {
  @AppStorage("appearance") private var appearance: Appearance = .system

  init() {
    #if DEBUG
      Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/iOSInjection.bundle")?.load()
    #endif
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
        .onAppear {
          applyAppearance()
          NotificationManager.requestAuthorization()
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
