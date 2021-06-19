//
//  SettingsView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/06/2021.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var showThumbnail = true
    @State private var isHapticOn = false
    let viewModel: SettingsViewModel

    var body: some View {
        NavigationView {
            Form {
                // General
                Section(header: Text("General")) {
                    Text("Home section order")

                    Toggle(isOn: $showThumbnail) {
                        Text("Display thumbnails")
                    }

                    HStack {
                        Text("Discography mode")
                        Spacer()
                        Text("Complete")
                            .font(.body)
                            .foregroundColor(.gray)
                    }

                    Toggle(isOn: $isHapticOn) {
                        Text("Haptic effect")
                    }
                }

                // Bug reports
                Section(header: Text("Bug reports & feature request"),
                        footer: bottomFooterView) {
                    // Twitter
                    URLButton(urlString: "https://twitter.com/ma_mobile_app") {
                        HStack {
                            SettingsIconView(image: Image("Twitter"))
                            Text("Twitter")
                        }
                    }

                    // Facebook
                    URLButton(urlString: "https://www.facebook.com/MetalArchivesIOSApp") {
                        HStack {
                            SettingsIconView(image: Image("Facebook"))
                            Text("Facebook")
                        }
                    }

                    // Github
                    URLButton(urlString: "https://github.com/ntnhon/Metal-Archives-iOS") {
                        HStack {
                            if colorScheme == .light {
                                SettingsIconView(image: Image("Github"))
                            } else {
                                SettingsIconView(image: Image("Github")
                                                    .renderingMode(.template))
                                    .foregroundColor(.primary)
                            }
                            Text("Github")
                        }
                    }

                    // Email
                    URLButton(urlString: "mailto:hi@nguyenthanhnhon.info") {
                        HStack {
                            SettingsIconView(image: Image(systemName: "envelope.fill"))
                            Text("Email")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }

    private var bottomFooterView: some View {
        VStack {
            HStack(spacing: 0) {
                Text("Made with 🤘 by ")
                URLButton(urlString: "https://twitter.com/_ntnhon") {
                    Text("Nhon Nguyen")
                        .fontWeight(.medium)
                        .foregroundColor(.accentColor)
                }
            }

            Spacer()

            HStack(spacing: 0) {
                Text("App icon designed by ")
                URLButton(urlString: "https://twitter.com/nrthrndarkness") {
                    Text("Matt Stewart")
                        .fontWeight(.medium)
                        .foregroundColor(.accentColor)
                }
            }

            Spacer()

            Text("Version \(viewModel.versionName) (Build \(viewModel.buildNumber))")
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: .init())
        SettingsView(viewModel: .init())
            .environment(\.colorScheme, .dark)
    }
}

private struct SettingsIcon: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scaledToFit()
            .frame(width: 18, height: 18)
    }
}

private struct SettingsIconView: View {
    let image: Image

    var body: some View {
        image
            .resizable()
            .scaledToFit()
            .frame(width: 18, height: 18)
    }
}

// TODO: Use this when Swift 5.5 becomes official
private extension ViewModifier where Self == SettingsIcon {
    static var settingsIcon: SettingsIcon { .init() }
}
