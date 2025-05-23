//
//  PrivacyOverlayViewModifier.swift
//  Toolbox.io
//
//  Created by denis0001-dev on 23.05.2025.
//

import SwiftUI

class PrivacyOverlayState: ObservableObject {
    @Published var showPrivacyOverlay: Bool = false
    @Published var privacyOverlayOpacity: Double = 1.0
}

struct PrivacyOverlayViewModifier: ViewModifier {
    @EnvironmentObject var state: PrivacyOverlayState
    @AppStorage("dontShowInRecents") private var dontShowInRecents = false
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if dontShowInRecents && (state.showPrivacyOverlay || (state.privacyOverlayOpacity < 1.0 && state.privacyOverlayOpacity != 0)) {
                    VisualEffectBlur(blurRadius: 20)
                        .ignoresSafeArea()
                        .opacity(state.privacyOverlayOpacity)
                        .animation(.easeInOut(duration: 0.3), value: state.privacyOverlayOpacity)
                        .overlay(
                            Image(systemName: "eye.slash")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary)
                        )
                }
            }
    }
}
