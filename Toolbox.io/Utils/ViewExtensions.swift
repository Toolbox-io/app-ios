//
//  ViewExtensions.swift
//  Toolbox.io
//
//  Created by denis0001-dev on 08.05.2025.
//

import SwiftUI

@inlinable func Navigation(@ViewBuilder content: () -> some View) -> some View {
    if #available(iOS 16.0, *) {
        return NavigationStack(root: content)
    } else {
        return NavigationView(content: content)
    }
}

private struct Static {
    @Environment(\.colorScheme)
    static var colorScheme: ColorScheme
}

extension View {
    /// Sets the presentation background of the enclosing sheet using a shape
    /// style.
    ///
    /// The following example uses the ``Material/thick`` material as the sheet
    /// background:
    ///
    ///     struct ContentView: View {
    ///         @State private var showSettings = false
    ///
    ///         var body: some View {
    ///             Button("View Settings") {
    ///                 showSettings = true
    ///             }
    ///             .sheet(isPresented: $showSettings) {
    ///                 SettingsView()
    ///                     .presentationBackground(.thickMaterial)
    ///             }
    ///         }
    ///     }
    ///
    /// The `presentationBackground(_:)` modifier differs from the
    /// ``View/background(_:ignoresSafeAreaEdges:)`` modifier in several key
    /// ways. A presentation background:
    ///
    /// * Automatically fills the entire presentation.
    /// * Allows views behind the presentation to show through translucent
    ///   styles.
    ///
    /// - Parameter style: The shape style to use as the presentation
    ///   background.
    @inlinable nonisolated public func presentationBackgroundC<S>(_ style: S) -> some View where S : ShapeStyle {
        if #available(iOS 16.4, *) {
            return self.presentationBackground(style)
        } else {
            return self
        }
    }


    /// Sets the presentation background of the enclosing sheet to a custom
    /// view.
    ///
    /// The following example uses a yellow view as the sheet background:
    ///
    ///     struct ContentView: View {
    ///         @State private var showSettings = false
    ///
    ///         var body: some View {
    ///             Button("View Settings") {
    ///                 showSettings = true
    ///             }
    ///             .sheet(isPresented: $showSettings) {
    ///                 SettingsView()
    ///                     .presentationBackground {
    ///                         Color.yellow
    ///                     }
    ///             }
    ///         }
    ///     }
    ///
    /// The `presentationBackground(alignment:content:)` modifier differs from
    /// the ``View/background(alignment:content:)`` modifier in several key
    /// ways. A presentation background:
    ///
    /// * Automatically fills the entire presentation.
    /// * Allows views behind the presentation to show through translucent
    ///   areas of the `content`.
    ///
    /// - Parameters:
    ///   - alignment: The alignment that the modifier uses to position the
    ///     implicit ``ZStack`` that groups the background views. The default is
    ///     ``Alignment/center``.
    ///   - content: The view to use as the background of the presentation.
    @inlinable nonisolated public func presentationBackgroundC<V>(alignment: Alignment = .center, @ViewBuilder content: () -> V) -> some View where V : View {
        if #available(iOS 16.4, *) {
            return self.presentationBackground(alignment: alignment, content: content)
        } else {
            return self
        }
    }
    
    @inlinable nonisolated func presentation() -> some View {
        if #available(iOS 16.0, *) {
            return self
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackgroundC(Color(.systemBackground))
        } else {
            return self
        }
    }
    
    @inlinable nonisolated func hideScrollContentBackground() -> some View {
        if #available(iOS 16.0, *) {
            return self
                .scrollContentBackground(.hidden)
        } else {
            return self
        }
    }
    
    nonisolated func listBackground() -> some View {
        return self.background(
            Color(
                UITraitCollection.current.userInterfaceStyle == .light ? .secondarySystemBackground : .systemBackground
            )
        )
    }

    @inlinable nonisolated func invisibleAndDisabled(_ condition: Bool) -> some View {
        return self
            .opacity(condition ? 0 : 1)
            .disabled(condition)
    }
}

extension TabView {
    
}

@inlinable func IconButton(_ systemName: String) -> some View {
    Image(systemName: systemName)
        .font(.headline)
        .foregroundColor(.accentColor)
}

@inlinable func LongButton(_ label: String, action: @escaping () -> Void) -> some View {
    LongButton(action: action, label: {
        Text(label)
    })
}

@inlinable func LongButton(
    action: @escaping () -> Void,
    @ViewBuilder label: () -> some View
) -> some View {
    Button(action: action) {
        label()
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .padding(.horizontal)
    }
    .buttonStyle(.borderedProminent)
    .frame(maxWidth: .infinity)
}

@inlinable func openURL(_ url: String) {
    UIApplication.shared.open(URL(string: url).unsafelyUnwrapped)
}
