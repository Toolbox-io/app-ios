//
//  SceneDelegate.swift
//  Toolbox.io
//
//  Created by denis0001-dev on 23.05.2025.
//

import UIKit
import SwiftUI
import Combine

final class SceneDelegate: NSObject, UIWindowSceneDelegate {
    var currentPhase: ScenePhase? = nil
  var secondaryWindow: UIWindow?
  var privacyOverlayState = PrivacyOverlayState()
  var cancellables = Set<AnyCancellable>()

  func scene(_ scene: UIScene,
             willConnectTo session: UISceneSession,
             options connectionOptions: UIScene.ConnectionOptions) {
      if let windowScene = scene as? UIWindowScene {
          setupSecondaryOverlayWindow(in: windowScene)
          setupPrivacyOverlayScenePhaseObservation()
      }
  }

  func setupSecondaryOverlayWindow(in scene: UIWindowScene) {
      let secondaryViewController = UIHostingController(
          rootView:
              EmptyView()
                  .frame(maxWidth: .infinity, maxHeight: .infinity)
                  .modifier(PrivacyOverlayViewModifier())
                  .environmentObject(privacyOverlayState)
      )
    secondaryViewController.view.backgroundColor = .clear
    let secondaryWindow = PassThroughWindow(windowScene: scene)
    secondaryWindow.rootViewController = secondaryViewController
    secondaryWindow.isHidden = false
    self.secondaryWindow = secondaryWindow
  }

  func setupPrivacyOverlayScenePhaseObservation() {
      // Observe scene phase changes
      NotificationCenter.default.publisher(for: UIScene.didActivateNotification)
          .sink { [weak self] _ in
              self?.handleScenePhaseChange(.active)
          }
          .store(in: &cancellables)
      NotificationCenter.default.publisher(for: UIScene.willDeactivateNotification)
          .sink { [weak self] _ in
              self?.handleScenePhaseChange(.inactive)
          }
          .store(in: &cancellables)
      NotificationCenter.default.publisher(for: UIScene.didEnterBackgroundNotification)
          .sink { [weak self] _ in
              self?.handleScenePhaseChange(.background)
          }
          .store(in: &cancellables)
  }

  func handleScenePhaseChange(_ phase: ScenePhase) {
      currentPhase = phase
      let dontShowInRecents = UserDefaults.standard.bool(forKey: "dontShowInRecents")
      if dontShowInRecents {
          if PrivacyOverlayAuthInProgress.shared.isAuthenticating {
              print("auth in progress, not showing overlay")
              return
          }
          if phase == .background || phase == .inactive {
              DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                  if self.currentPhase == .background || self.currentPhase == .inactive {
                      withAnimation(.easeInOut(duration: 0.3)) {
                        print("showing overlay")
                          self.privacyOverlayState.privacyOverlayOpacity = 1.0
                          self.privacyOverlayState.showPrivacyOverlay = true
                      }
                  }
              }
          } else if phase == .active {
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                  withAnimation(.easeInOut(duration: 0.3)) {
                      self.privacyOverlayState.privacyOverlayOpacity = 0.0
                  }
                  DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                      self.privacyOverlayState.showPrivacyOverlay = false
                      self.privacyOverlayState.privacyOverlayOpacity = 1.0
                  }
              }
          } else {
            print("\(phase)")
          }
      }
  }
}

enum ScenePhase {
    case active, inactive, background
}
