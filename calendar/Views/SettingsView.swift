import SwiftUI

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
    @AppStorage("appearance") private var appearance: Appearance = .system // Persist choice

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
            }
            .navigationTitle("Settings")
            .onChange(of: appearance) {
                applyAppearance()
            }
        }
    }

    /// Apply appearance mode based on selection
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
    
    struct SettingsRow: View {
        var title: String
        
        var body: some View {
            HStack {
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
            }        }
    }
}
