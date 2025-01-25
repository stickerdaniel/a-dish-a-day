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
    var notificationManager = NotificationManager()
    // MARK: - SwiftData model context
    @Environment(\.modelContext) private var modelContext

    // MARK: - Appearance
    @AppStorage("appearance") private var appearance: Appearance = .system

    // MARK: - Notifications Toggle
    @Query private var importedCalendars: [CalendarModel]
    
    var filteredImportedCalendars: [CalendarModel] {
        importedCalendars.filter { $0.source == .imported || $0.source == nil }
    }
    
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
                // OpenAI API Key Section
                Section {
                    SecureField("API Key", text: $apiKey)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .onChange(of: apiKey) {
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

                // Notifications Toggle if filteredImportedCalendars is not empty
                if !filteredImportedCalendars.isEmpty {
                    Section("Notifications") {
                        ForEach(filteredImportedCalendars) { calendar in
                            Toggle(calendar.name, isOn: Binding(
                                get: {
                                    UserDefaults.standard.bool(forKey: "calendar_notifications_\(calendar.id)")
                                },
                                set: { enabled in
                                    if enabled {
                                        notificationManager.scheduleNotifications(for: calendar)
                                    } else {
                                        notificationManager.deleteNotifications(for: calendar)
                                    }
                                }
                            ))
                        }
                    }
                }

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
                    notificationManager.deleteAllNotifications()
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
