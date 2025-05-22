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
    @AppStorage("dontShowInRecents") private var dontShowInRecents = false
    private var blurRadius: Double = 10
    @Environment(\.scenePhase) private var scenePhase
    @State private var isPresented = false
    @State private var showPrivacyOverlay = false
    
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
            // Privacy overlay
            if dontShowInRecents && showPrivacyOverlay {
                VisualEffectBlur(blurRadius: blurRadius)
                    .ignoresSafeArea()
                    .overlay(
                        Image(systemName: "eye.slash")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                    )
                    .transition(.opacity)
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if dontShowInRecents {
                if newPhase == .background || newPhase == .inactive {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showPrivacyOverlay = true
                    }
                } else if newPhase == .active {
                    // Remove overlay after a short delay to avoid flicker
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showPrivacyOverlay = false
                        }
                    }
                }
            }
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

// VisualEffectBlur for iOS 15+ with customizable radius
struct VisualEffectBlur: UIViewRepresentable {
    var blurRadius: Double
    func makeUIView(context: Context) -> UIVisualEffectView {
        let blur = UIBlurEffect(style: .systemMaterial)
        let view = UIVisualEffectView(effect: blur)
        view.layer.masksToBounds = true
        view.clipsToBounds = true
        // Custom blur radius (iOS 15+ private API, not App Store safe, but for demo):
        if let blurLayer = view.layer.sublayers?.first(where: { String(describing: type(of: $0)).contains("BackdropLayer") }) {
            blurLayer.setValue(blurRadius, forKeyPath: "filters.gaussianBlur.inputRadius")
        }
        return view
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        if let blurLayer = uiView.layer.sublayers?.first(where: { String(describing: type(of: $0)).contains("BackdropLayer") }) {
            blurLayer.setValue(blurRadius, forKeyPath: "filters.gaussianBlur.inputRadius")
        }
    }
}

#Preview {
    ContentView()
}
