//
//  SettingsView.swift
//  calendar
//
//  Created by Daniel Sticker on 15.01.25.
//

import SwiftUI
import SwiftData

enum Appearance: String, CaseIterable {
    case light, dark, system

    var title: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .system: return "System"
        }
    }
}

struct SettingsView: View {
    // MARK: - SwiftData model context
    @Environment(\.modelContext) private var modelContext

    // MARK: - Appearance
    @AppStorage("appearance") private var appearance: Appearance = .system

    // MARK: - Notifications Toggle
    @State private var notificationsEnabled: Bool = false

    // MARK: - Clear Data Confirmation
    @State private var showClearDataConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                // Notifications Toggle
                Section("Notifications") {
                    Toggle("New Recipe Unlocked", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) {
                            toggleNotifications()
                        }
                }

                // Appearance Picker Section
                Picker("Appearance", selection: $appearance) {
                    ForEach(Appearance.allCases, id: \.self) { appearance in
                        Text(appearance.title).tag(appearance)
                    }
                }
                .pickerStyle(.inline)

                // Data Management Section
                Section("Data Management") {
                    Button("Clear All Data") {
                        showClearDataConfirmation = true
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog("Are you sure you want to clear all data? This action cannot be undone.", isPresented: $showClearDataConfirmation, titleVisibility: .visible) {
                Button("Confirm", role: .destructive) {
                    clearAllData()
                    // Dismiss the view to close the sheet
                }
                Button("Cancel", role: .cancel) {}
            }
            .onChange(of: appearance) {
                applyAppearance()
            }
        }
    }

    // MARK: - Toggle Notifications
    private func toggleNotifications() {
        // Placeholder for the notifications toggle logic
        print("Notifications toggled: \(notificationsEnabled)")
    }

    // MARK: - Clear All Data
    private func clearAllData() {
        do {
            // Delete all objects for each of your SwiftData model types
            try modelContext.delete(model: RecipeModel.self)
            try modelContext.delete(model: CalendarModel.self)

            // Explicitly save to ensure deletions are committed
            try modelContext.save()
            print("All data cleared successfully.")
            
            // TODO show dialog that says success
        } catch {
            print("Failed to clear data: \(error.localizedDescription)")
            // TODO show dialog that says failure with error
        }
    }

    // MARK: - Apply Appearance
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
