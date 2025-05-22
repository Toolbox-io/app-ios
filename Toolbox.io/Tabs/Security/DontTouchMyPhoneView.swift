import SwiftUI

struct DontTouchMyPhoneView: View {
    var body: some View {
        List {
            Section {
                Text("Don't Touch My Phone settings will go here.")
            }
        }
        .navigationTitle("Don't Touch My Phone")
    }
}

#Preview {
    DontTouchMyPhoneView()
} 