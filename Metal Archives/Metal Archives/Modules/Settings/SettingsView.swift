//
//  SettingsView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/06/2021.
//

import StoreKit
import SwiftUI

struct SettingsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var settings: Settings

    @State private var showAboutSheet = false
    @State private var showSupportSheet = false

    private let versionName =
        (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "?"
    private let buildNumber =
        (Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? "?"

    var body: some View {
        NavigationView {
            Form {
                // General
                Section(header: Text("General")) {
                    Text("Home section order")

                    Toggle(isOn: settings.$showThumbnails) {
                        Text("Display thumbnails")
                    }

                    HStack {
                        Text("Discography mode")
                        Spacer()
                        Text("Complete")
                            .font(.body)
                            .foregroundColor(.gray)
                    }

                    Toggle(isOn: settings.$useHaptic) {
                        Text("Haptic effect")
                    }
                }

                // Information
                Section(header: Text("Information")) {
                    // About
                    Button(action: {
                        showAboutSheet = true
                    }, label: {
                        HStack {
                            SettingsIconView(image: Image(systemName: "info.circle.fill"))
                                .foregroundColor(.blue)
                            Text("About")
                                .foregroundColor(.primary)
                        }
                    })
                    .sheet(isPresented: $showAboutSheet) {
                        AboutView()
                    }

                    // Share
                    URLButton(urlString: "https://apps.apple.com/us/app/id1074038930") {
                        HStack {
                            SettingsIconView(image: Image(systemName: "square.and.arrow.up.fill"))
                                .foregroundColor(.green)
                            Text("Share")
                        }
                    }

                    // Rate
                    Button(action: {
                        SKStoreReviewController.askForReview()
                    }, label: {
                        HStack {
                            SettingsIconView(image: Image(systemName: "heart.circle.fill"))
                                .foregroundColor(.red)
                            Text("Rate & review")
                                .foregroundColor(.primary)
                        }
                    })

                    // Support
                    Button(action: {
                        showSupportSheet = true
                    }, label: {
                        HStack {
                            SettingsIconView(image: Image(systemName: "hands.clap.fill"))
                                .foregroundColor(.purple)
                            Text("Support this effort")
                                .foregroundColor(.primary)
                        }
                    })
                    .sheet(isPresented: $showSupportSheet) {
                        SupportView()
                    }
                }

                // Official Links
                Section(header: Text("Official Links")) {
                    // Website
                    URLButton(urlString: "https://www.metal-archives.com/") {
                        HStack {
                            SettingsIconView(image: Image(systemName: "link"))
                            Text("Website")
                        }
                    }

                    // Forum
                    URLButton(urlString: "https://www.metal-archives.com/board/") {
                        HStack {
                            SettingsIconView(image: Image(systemName: "globe"))
                            Text("Forum")
                        }
                    }
                }

                // Mobile Application Links
                Section(header: Text("Mobile Application Links"),
                        footer: Text("For crashes, bug reports & feature requests related to this iOS app")) {
                    // Twitter
                    URLButton(urlString: "https://twitter.com/ma_mobile_app") {
                        HStack {
                            SettingsIconView(image: Image("Twitter"))
                            Text("Twitter")
                        }
                    }

                    // Facebook
                    URLButton(urlString: "https://www.facebook.com/MetalArchivesMobileApp") {
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
                            Text("Author's email")
                        }
                    }
                }

                // Empty section
                Section(footer: bottomFooterView) {}
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

            Text("Version \(versionName) (Build \(buildNumber))")
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
        SettingsView()
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
