//
//  SettingsView.swift
//  Toolbox.io
//
//  Created by denis0001-dev on 21.05.2025.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("theme") private var theme = "system"
    @AppStorage("beta") private var beta = false
    
    var body: some View {
        List {
            Section(header: Text("Customization"), content: {
                Picker("Theme", selection: $theme) {
                    Text("Light").tag("light")
                    Text("Dark").tag("dark")
                    Text("As System").tag("system")
                }
            })
            Section(header: Text("Other"), content: {
                Toggle("Use beta version", isOn: $beta)
            })
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
    }
}

#Preview {
    SettingsView()
}
