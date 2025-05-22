import SwiftUI

struct ToolsView: View {
    var body: some View {
        List {
            Section {
                NavigationLink(destination: AppManagerView()) {
                    Label("App Manager", systemImage: "apps.iphone")
                }
                NavigationLink(destination: NotificationHistoryView()) {
                    Label("Notification History", systemImage: "bell.badge")
                }
                // Add more tools as needed
            }
        }
        .navigationTitle("Tools")
    }
}

#Preview {
    ToolsView()
} 