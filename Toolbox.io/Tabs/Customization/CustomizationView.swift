import SwiftUI

struct CustomizationView: View {
    var body: some View {
        List {
            Section {
                NavigationLink(destination: TilesView()) {
                    Label("Tiles", systemImage: "square.grid.2x2")
                }
                NavigationLink(destination: ShortcutsView()) {
                    Label("Shortcuts", systemImage: "bolt.fill")
                }
            }
        }
        .navigationTitle("Customization")
    }
}

#Preview {
    CustomizationView()
} 