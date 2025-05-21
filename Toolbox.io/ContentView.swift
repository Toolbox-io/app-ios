//
//  ContentView.swift
//  Toolbox.io
//
//  Created by denis0001-dev on 21.05.2025.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("theme") private var theme = "system"
    @State private var isPresented = true
    
    var body: some View {
        TabView {
            Navigation {
                VStack {
                    
                }
                .navigationTitle("Home")
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            
            Navigation {
                VStack {
                    
                }
                .navigationTitle("Security")
            }
            .tabItem {
                Label("Security", systemImage: "lock.shield.fill")
            }
            
            
            Navigation {
                VStack {
                    
                }
                .navigationTitle("Customization")
            }
            .tabItem {
                Label("Customization", systemImage: "paintpalette.fill")
            }
            
            Navigation {
                VStack {
                    
                }
                .navigationTitle("Tools")
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
        .onAppear {
            isPresented = true
        }
        .fullScreenCover(isPresented: $isPresented) {
            AuthView()
        }
    }
}

#Preview {
    ContentView()
}
