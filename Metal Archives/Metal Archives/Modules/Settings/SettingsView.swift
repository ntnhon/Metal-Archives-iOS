//
//  SettingsView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/06/2021.
//

import StoreKit
import SwiftUI

private let kVersionName =
    (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "?"
private let kBuildNumber =
    (Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? "?"

struct SettingsView: View {
    @EnvironmentObject private var preferences: Preferences

    @State private var showAboutSheet = false
    @State private var showSupportSheet = false

    @State private var showThumbnails = false
    @State private var useHaptic = false
    @State private var showThemePreview = false

    var body: some View {
        let primaryColor = preferences.theme.primaryColor
        NavigationView {
            Form {
                // General
                Section(header: Text("General")) {
                    NavigationLink(destination: HomeSectionOrderView()) {
                        Text("Home section order")
                    }

                    Toggle("Show thumbnails", isOn: $showThumbnails)
                        .onChange(of: showThumbnails) { isOn in
                            preferences.showThumbnails = isOn
                            preferences.objectWillChange.send()
                        }

                    NavigationLink(destination: DiscographyModeView()) {
                        HStack {
                            Text("Default discography mode")
                            Spacer()
                            Text(preferences.discographyMode.description)
                                .font(.body)
                                .foregroundColor(.gray)
                        }
                    }

                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Default order by date")
                            Picker("", selection: preferences.$dateOrder) {
                                Text("Ascending ↑")
                                    .tag(Order.ascending)
                                Text("Descending ↓")
                                    .tag(Order.descending)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                    }

                    Toggle("Haptic effect", isOn: $useHaptic)
                        .onChange(of: useHaptic) { isOn in
                            preferences.useHaptic = isOn
                            preferences.objectWillChange.send()
                        }
                }

                // Theme
                Section(header: Text("Theme")) {
                    HStack(spacing: 16) {
                        ForEach(Theme.allCases, id: \.self) { theme in
                            ZStack {
                                Circle()
                                    .frame(width: 28, height: 28)
                                    .foregroundColor(theme == preferences.theme ? .primary : .clear)
                                theme.primaryColor
                                    .frame(width: 24, height: 24)
                                    .clipShape(Circle())
                            }
                            .onTapGesture {
                                withAnimation {
                                    preferences.theme = theme
                                    preferences.objectWillChange.send()
                                    showThemePreview = true
                                }
                            }
                        }
                    }

                    if showThemePreview {
                        themePreview
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
                            .accentColor(primaryColor)
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
                            .accentColor(primaryColor)
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
                            SettingsIconView(image: Image("Github")
                                                .renderingMode(.template))
                                .foregroundColor(.primary)
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
        .onAppear {
            self.showThumbnails = preferences.showThumbnails
            self.useHaptic = preferences.useHaptic
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

            Text("Version \(kVersionName) (Build \(kBuildNumber))")
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var themePreview: some View {
        VStack(alignment: .leading) {
            Text("How it looks 👇")

            HStack(spacing: 8) {
                Image("TSOP")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64)

                VStack(alignment: .leading, spacing: 2) {
                    Text("The Sound of Perserverance")
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(preferences.theme.primaryColor)
                    Text("Death")
                        .font(.callout)
                        .fontWeight(.bold)
                        .foregroundColor(preferences.theme.secondaryColor)
                    Text("1998 • Full-length")
                        .font(.footnote)
                        .fontWeight(.medium)
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environment(\.colorScheme, .dark)
            .environmentObject(Preferences())
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
