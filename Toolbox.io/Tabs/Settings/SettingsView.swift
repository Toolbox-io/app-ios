//
//  SettingsView.swift
//  Toolbox.io
//
//  Created by denis0001-dev on 21.05.2025.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("theme") private var theme = "system"
    @AppStorage("dontShowInRecents") private var dontShowInRecents = false
    @AppStorage("allowBiometric") private var allowBiometric = false
    @AppStorage("passwordLockEnabled") private var passwordLockEnabled = false
    @AppStorage("passwordLockHash") private var passwordLockHash = ""
    @AppStorage("checkForUpdates") private var checkForUpdates = true
    
    @State private var showPasswordSheet = false
    @State private var passwordStep: PasswordStep = .none
    @State private var tempNewPassword: String? = nil

    enum PasswordStep {
        case none
        case enterOld
        case enterNew
        case confirmNew
    }

    var body: some View {
        List {
            Section(header: Text("Security")) {
                Button(action: {
                    if passwordLockEnabled {
                        passwordStep = .enterOld
                    } else {
                        passwordStep = .enterNew
                    }
                    showPasswordSheet = true
                }) {
                    HStack {
                        Label("Password lock", systemImage: "key.fill")
                        Spacer()
                        Text(passwordLockEnabled ? "Enabled" : "Disabled")
                            .foregroundColor(passwordLockEnabled ? .green : .secondary)
                            .font(.subheadline)
                    }
                }
                .buttonStyle(.plain)
                Toggle(isOn: $allowBiometric) {
                    Label("Allow biometric", systemImage: "faceid")
                }
                Toggle(isOn: $dontShowInRecents) {
                    Label("Don't show in recents", systemImage: "eye.slash")
                }
            }
            Section(header: Text("Customization")) {
                Picker("Theme", selection: $theme) {
                    Text("Light").tag("light")
                    Text("Dark").tag("dark")
                    Text("As System").tag("system")
                }
            }
            Section(header: Text("Other")) {
                Toggle(isOn: $checkForUpdates) {
                    Label("Check for updates", systemImage: "arrow.down.circle")
                }
            }
        }
        .navigationTitle("Settings")
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                NavigationLink {
                    AboutView()
                } label: {
                    IconButton("info.circle")
                }
            }
        }
        .sheet(isPresented: $showPasswordSheet, onDismiss: {
            passwordStep = .none
            tempNewPassword = nil
        }) {
            PasswordLockFlowSheet(
                step: $passwordStep,
                showSheet: $showPasswordSheet,
                tempNewPassword: $tempNewPassword,
                passwordLockEnabled: $passwordLockEnabled,
                passwordLockHash: $passwordLockHash
            )
        }
    }
}

struct PasswordLockFlowSheet: View {
    @Binding var step: SettingsView.PasswordStep
    @Binding var showSheet: Bool
    @Binding var tempNewPassword: String?
    @Binding var passwordLockEnabled: Bool
    @Binding var passwordLockHash: String

    var body: some View {
        ZStack {
            switch step {
            case .enterOld:
                AuthView(mode: .enterOldPassword, onSuccess: { pin in
                    if let pin = pin, AuthView.hashPin(pin) == passwordLockHash {
                        passwordLockEnabled = false
                        passwordLockHash = ""
                        showSheet = false
                    }
                }, newPassword: nil)
                    .transition(.move(edge: .trailing))
            case .enterNew:
                AuthView(mode: .enterNewPassword, onSuccess: { pin in
                    if let pin = pin, pin.count == 4 {
                        tempNewPassword = pin
                        withAnimation {
                            step = .confirmNew
                        }
                    }
                }, newPassword: nil)
                    .transition(.move(edge: .leading))
            case .confirmNew:
                AuthView(mode: .confirmNewPassword, onSuccess: { pin in
                    if pin == tempNewPassword {
                        passwordLockHash = AuthView.hashPin(pin ?? "")
                        passwordLockEnabled = true
                        showSheet = false
                    }
                }, newPassword: tempNewPassword)
                    .transition(.move(edge: .trailing))
            case .none:
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .animation(.easeInOut, value: step)
    }
}

#Preview {
    SettingsView()
}

