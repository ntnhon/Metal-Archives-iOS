//
//  SettingsView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/06/2021.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.openURL) private var openURL
    @State private var showThumbnail = true
    @State private var isHapticOn = false
    let viewModel: SettingsViewModel

    var body: some View {
        Form {
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

            Section(header: Text("Bug reports & feature request"),
                    footer: bottomFooterView) {
                // Twitter
                HStack {
                    Image("Twitter")
                        .resizable()
                        .modifier(SettingsIcon())
                    Text("Twitter")
                }

                // Facebook
                HStack {
                    Image("Facebook")
                        .resizable()
                        .modifier(SettingsIcon())
                    Text("Facebook")
                }

                // Github
                HStack {
                    Image("Github")
                        .resizable()
                        .modifier(SettingsIcon())
                    Text("Github")
                }

                // Email
                HStack {
                    Image(systemName: "envelope.fill")
                        .resizable()
                        .modifier(SettingsIcon())
                    Text("Email")
                }
            }
        }
        .navigationTitle("Settings")
    }

    private var bottomFooterView: some View {
        VStack {
            HStack {
                Text("Made with 🤘 by")
                Button(action: {
                        open(urlString: "https://twitter.com/_ntnhon")
                }, label: {
                    Text("Nhon Nguyen")
                })
            }

            Spacer()

            HStack {
                Text("Icon designed by")
                Button(action: {
                        open(urlString: "https://twitter.com/nrthrndarkness")
                }, label: {
                    Text("Matt Stewart")
                })
            }

            Spacer()

            Text("Version \(viewModel.versionName) (Build \(viewModel.buildNumber))")
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func open(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        openURL(url)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView(viewModel: .init())
        }
    }
}

private struct SettingsIcon: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scaledToFit()
            .frame(width: 18, height: 18)
    }
}

// TODO: Use this when Swift 5.5 becomes official
private extension ViewModifier where Self == SettingsIcon {
    static var settingsIcon: SettingsIcon { .init() }
}
