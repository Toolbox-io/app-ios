//
//  PassthroughWindow.swift
//  Toolbox.io
//
//  Created by denis0001-dev on 23.05.2025.
//

import UIKit

class PassThroughWindow: UIWindow {
  override func hitTest(_ point: CGPoint,
                        with event: UIEvent?) -> UIView? {
    guard let hitView = super.hitTest(point, with: event)
    else { return nil }

    return rootViewController?.view == hitView ? nil : hitView
  }
}
