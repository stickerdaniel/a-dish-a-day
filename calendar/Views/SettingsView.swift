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
    
    // MARK: - OpenAI API Key
    @AppStorage("openai_api_key") private var apiKey: String = ""
    @State private var showAPIKeyValidationError = false
    @State private var apiKeyValidationError: String?

    // MARK: - Clear Data Confirmation & Feedback
    @State private var showClearDataConfirmation = false
    @State private var showClearDataSuccess = false
    @State private var clearDataError: String?

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
                
                // OpenAI API Key Section
                Section {
                    SecureField("API Key", text: $apiKey)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .onChange(of: apiKey) { _ in
                            validateAPIKey()
                        }
                } header: {
                    Text("OpenAI Integration")
                } footer: {
                    Group {
                        if let error = apiKeyValidationError {
                            Text(error)
                                .foregroundColor(.red)
                        } else {
                            Text("To obtain an API key, visit the [OpenAI website](https://platform.openai.com/api-keys).")
                                .tint(.blue)
                        }
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
            .confirmationDialog(
                "Are you sure you want to clear all data? This action cannot be undone.",
                isPresented: $showClearDataConfirmation,
                titleVisibility: .visible
            ) {
                Button("Confirm", role: .destructive) {
                    clearAllData()
                }
                Button("Cancel", role: .cancel) {}
            }
            .alert("Success", isPresented: $showClearDataSuccess) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("All data was cleared successfully.")
            }
            .alert("Error", isPresented: Binding(
                get: { clearDataError != nil },
                set: { if !$0 { clearDataError = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                if let error = clearDataError {
                    Text("Failed to clear data: \(error)")
                }
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
            showClearDataSuccess = true
        } catch {
            print("Failed to clear data: \(error.localizedDescription)")
            clearDataError = error.localizedDescription
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
    
    // MARK: - Validate API Key
    private func validateAPIKey() {
        // Basic validation
        if apiKey.isEmpty {
            apiKeyValidationError = "Please enter an OpenAI API key."
            showAPIKeyValidationError = true
            return
        }
        
        // Check if the API key follows the expected format (starts with 'sk-')
        if !apiKey.starts(with: "sk-") {
            apiKeyValidationError = "Invalid API key format. The key should start with 'sk-'."
            showAPIKeyValidationError = true
            return
        }
        
        // Clear any previous errors if validation passes
        apiKeyValidationError = nil
        showAPIKeyValidationError = false
    }
}
