import SwiftUI

struct SecurityView: View {
    var body: some View {
        List {
            Section {
                NavigationLink(destination: UnlockProtectionView()) {
                    Label("Unlock Protection", systemImage: "lock.shield")
                }
                NavigationLink(destination: AppLockerView()) {
                    Label("App Locker", systemImage: "app.badge.shield.checkmark")
                }
                NavigationLink(destination: DontTouchMyPhoneView()) {
                    Label("Don't Touch My Phone", systemImage: "hand.raised.fill")
                }
            }

            Section {
                NavigationLink(destination: SecurityActionsView()) {
                    Label("Security Actions", systemImage: "exclamationmark.shield")
                }
            }
        }
        .navigationTitle("Security")
    }
}

#Preview {
    SecurityView()
} 