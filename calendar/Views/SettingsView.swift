import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            VStack {
                // First section
                VStack {
                    NavigationLink(destination: PrivacyView()) {
                        SettingsRow(title: "Privacy")
                    }
                    Divider()
                    NavigationLink(destination: NotificationsView()) {
                        SettingsRow(title: "Notifications")
                    }
                }
                .background(Color.white)
                .cornerRadius(10)
                .padding(.horizontal)

                // Second section
                VStack {
                    NavigationLink(destination: StorageView()) {
                        SettingsRow(title: "Storage")
                    }
                    Divider()
                    NavigationLink(destination: AboutView()) {
                        SettingsRow(title: "About")
                    }
                }
                .background(Color.white)
                .cornerRadius(10)
                .padding(.horizontal)
                
                VStack {
                    NavigationLink(destination: HelpView()) {
                        SettingsRow(title: "Help")
                    }
                }
                .background(Color.white)
                .cornerRadius(10)
                .padding(.horizontal)
                
               

                // Other buttons
                VStack {
                    NavigationLink(destination: LogoutView()) {
                        SettingsRow(title: "Log out")
                    }
                }
                .background(Color.white)
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 50)

                Spacer()
            }
            .background(Color(UIColor.systemGray6)) // Light gray background
            .navigationBarTitle("Settings", displayMode: .inline)
        }
    }
}

// Reusable Row Component
struct SettingsRow: View {
    var title: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.black)
                .padding()
            Spacer()
        }
        .frame(height: 50)
    }
}

// Dummy Views for Navigation
struct PrivacyView: View { var body: some View { Text("Privacy Settings").navigationTitle("Privacy") } }
struct NotificationsView: View { var body: some View { Text("Notification Settings").navigationTitle("Notifications") } }
struct StorageView: View { var body: some View { Text("Storage Settings").navigationTitle("Storage") } }
struct AboutView: View { var body: some View { Text("About App").navigationTitle("About") } }
struct HelpView: View { var body: some View { Text("Help Center").navigationTitle("Help") } }
struct LogoutView: View { var body: some View { Text("Log Out").navigationTitle("Log out") } }

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
