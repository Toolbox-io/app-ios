//
//  ContentView.swift
//  Toolbox.io
//
//  Created by denis0001-dev on 21.05.2025.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("theme") private var theme = "system"
    @AppStorage("passwordLockEnabled") private var passwordLockEnabled = false
    @State private var isPresented = false
    
    var body: some View {
        ZStack {
            TabView {
                Navigation {
                    HomeView(isPresented: $isPresented)
                }
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                
                Navigation {
                    SecurityView()
                }
                .tabItem {
                    Label("Security", systemImage: "lock.shield.fill")
                }
                
                Navigation {
                    CustomizationView()
                }
                .tabItem {
                    Label("Customization", systemImage: "paintpalette.fill")
                }
                
                Navigation {
                    ToolsView()
                }
                .tabItem {
                    Label("Tools", systemImage: "wrench.and.screwdriver.fill")
                }
                
                Navigation {
                    SettingsView()
                }
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
            }
            .preferredColorScheme(
                theme == "system" ?
                    nil
                : theme == "dark" ? .dark : .light
            )
        }
        .onAppear {
            if passwordLockEnabled {
                isPresented = true
            }
        }
        .fullScreenCover(isPresented: $isPresented) {
            if passwordLockEnabled {
                AuthView(mode: .enterPassword, onSuccess: { _ in
                    isPresented = false
                }, newPassword: nil)
            }
        }
    }
}

#Preview {
    ContentView()
}
