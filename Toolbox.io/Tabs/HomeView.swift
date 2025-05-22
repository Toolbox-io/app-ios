import SwiftUI

struct HomeView: View {
    @Binding var isPresented: Bool

    var body: some View {
        List {
            Section {
                Text("Home content will go here.")
            }
        }
        .navigationTitle("Home")
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button(action: {
                    isPresented = true
                }) {
                    Image(systemName: "lock.fill")
                        .font(.headline)
                        .foregroundColor(.accentColor)
                }
            }
        }
    }
}

#Preview {
    HomeView(isPresented: Binding(get: { false }, set: {_ in }))
}
