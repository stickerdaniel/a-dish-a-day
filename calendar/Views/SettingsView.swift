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
    
    var body: some View {
        NavigationStack {
            Form {
                // First Section
                Section {
                    NavigationLink(destination: Text("Privacy Placeholder")) {
                        SettingsRow(title: "Privacy")
                    }
                    NavigationLink(destination: Text("Notifications Placeholder")) {
                        SettingsRow(title: "Notifications")
                    }
                }
                
                // Second Section
                Section {
                    NavigationLink(destination: Text("Storage Placeholder")) {
                        SettingsRow(title: "Storage")
                    }
                    NavigationLink(destination: Text("About Placeholder")) {
                        SettingsRow(title: "About")
                    }
                }
                
                // Help Section
                Section {
                    NavigationLink(destination: Text("Help Placeholder")) {
                        SettingsRow(title: "Help")
                    }
                }
                
                // Appearance Picker Section
                Picker("Appearance", selection: $appearance) {
                    ForEach(Appearance.allCases, id: \.self) { appearance in
                        Text(appearance.title).tag(appearance)
                    }
                }
                .pickerStyle(.inline)
                
                // Log Out Section
                Section {
                    NavigationLink(destination: Text("Log Out Placeholder")) {
                        SettingsRow(title: "Log out")
                    }
                }
                
                // Data Management: Clear All Data Button
                Section("Data Management") {
                    Button("Clear All Data") {
                        clearAllData()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
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
            // Add additional model deletes as necessary
            
            // Explicitly save to ensure deletions are committed
            try modelContext.save()
            print("All data cleared successfully.")
        } catch {
            print("Failed to clear data: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Appearance
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
    
    // MARK: - SettingsRow View
    struct SettingsRow: View {
        var title: String
        
        var body: some View {
            HStack {
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
            }
        }
    }
}
