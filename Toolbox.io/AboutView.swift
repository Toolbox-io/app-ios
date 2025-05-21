//
//  AboutView.swift
//  Toolbox.io
//
//  Created by denis0001-dev on 21.05.2025.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack {
            List {
                Section(
                    content: {
                        Button(action: {
                            openURL("https://toolbox-io.ru")
                        }) {
                            Label("Website", systemImage: "globe")
                        }
                        .contextMenu {
                            Button(action: {
                                openURL("https://toolbox-io.ru")
                            }) {
                                Label("Open", systemImage: "globe")
                            }
                            Button(action: {
                                openURL("https://beta.toolbox-io.ru")
                            }) {
                                Label("Open beta version", systemImage: "arrowshape.up.fill")
                            }
                        }
                        Button(action: {
                            openURL("https://github.com/Toolbox-io/Toolbox-io/issues/new/choose")
                        }) {
                            Label("Report a bug", systemImage: "exclamationmark.bubble.fill")
                        }
                    },
                    header: {
                        VStack {
                            AppIcon()
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            Text("Toolbox.io")
                                .font(.title)
                                .bold()
                                .padding(.bottom, 5)
                                .textCase(nil)
                                .foregroundColor(.primary)
                            Text("An app with a lot of useful things like security, customization and tools")
                                .multilineTextAlignment(.center)
                                .textCase(nil)
                                .foregroundColor(.primary)
                                .font(.system(size: 15))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom)
                    }
                )
                
            }
            Spacer()
        }
        .navigationTitle("About app")
    }
}

#Preview {
    AboutView()
}
