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

    @State private var selectedUrlString: String?

    var body: some View {
        Form {
            generalSection
            themeSection
            informationSection
            officiaLinksSection
            mobileAppLinksSection
            bottomSection
        }
        .navigationTitle("Settings")
        .betterSafariView(urlString: $selectedUrlString,
                          tintColor: preferences.theme.primaryColor)
        .onAppear {
            self.showThumbnails = preferences.showThumbnails
            self.useHaptic = preferences.useHaptic
        }
    }

    private var generalSection: some View {
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
    }

    private var themeSection: some View {
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
    }

    private var informationSection: some View {
        Section(header: Text("Information")) {
            // About
            Button(action: {
                showAboutSheet = true
            }, label: {
                Label(title: {
                    Text("About")
                        .foregroundColor(.primary)
                }, icon: {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                })
            })
            .sheet(isPresented: $showAboutSheet) {
                AboutView()
                    .tint(preferences.theme.primaryColor)
            }

            // Rate
            Button(action: {
                let urlString = "itms-apps://itunes.apple.com/gb/app/id1074038930?action=write-review&mt=8"
                if let url = URL(string: urlString),
                   UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }, label: {
                Label(title: {
                    Text("Rate & review")
                        .foregroundColor(.primary)
                }, icon: {
                    Image(systemName: "heart.circle.fill")
                        .foregroundColor(.red)
                })
            })

            // Support
            Button(action: {
                showSupportSheet = true
            }, label: {
                Label(title: {
                    Text("Support this effort")
                        .foregroundColor(.primary)
                }, icon: {
                    Image(systemName: "hands.clap.fill")
                        .foregroundColor(.purple)
                })
            })
            .sheet(isPresented: $showSupportSheet) {
                SupportView()
                    .accentColor(preferences.theme.primaryColor)
            }
        }
    }

    private var officiaLinksSection: some View {
        Section(header: Text("Official Links")) {
            Button(action: {
                selectedUrlString = "https://www.metal-archives.com/"
            }, label: {
                Label("Website", systemImage: "link")
                    .foregroundColor(.primary)
            })

            Button(action: {
                selectedUrlString = "https://www.metal-archives.com/board/"
            }, label: {
                Label("Forum", systemImage: "globe")
                    .foregroundColor(.primary)
            })
        }
    }

    private var mobileAppLinksSection: some View {
        Section(header: Text("Mobile Application Links"),
                footer: Text("For crashes, bug reports & feature requests related to this iOS app")) {
            // Twitter
            Button(action: {
                selectedUrlString = "https://twitter.com/ma_mobile_app"
            }, label: {
                Label(title: {
                    Text("Twitter")
                        .foregroundColor(.primary)
                }, icon: {
                    Image("Twitter")
                        .resizable()
                        .frame(width: 18, height: 18, alignment: .leading)
                })
            })

            // Facebook
            Button(action: {
                selectedUrlString = "https://www.facebook.com/MetalArchivesMobileApp"
            }, label: {
                Label(title: {
                    Text("Facebook")
                        .foregroundColor(.primary)
                }, icon: {
                    Image("Facebook")
                        .resizable()
                        .frame(width: 18, height: 18, alignment: .leading)
                })
            })

            // Github
            Button(action: {
                selectedUrlString = "https://github.com/ntnhon/Metal-Archives-iOS"
            }, label: {
                Label(title: {
                    Text("Github")
                        .foregroundColor(.primary)
                }, icon: {
                    Image("Github")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.primary)
                        .frame(width: 18, height: 18, alignment: .leading)
                })
            })

            // Email
            Button(action: {
                selectedUrlString = "mailto:hi@nguyenthanhnhon.info"
            }, label: {
                Label("Author's email", systemImage: "envelope.fill")
                    .foregroundColor(.primary)
            })
        }
    }

    private var bottomSection: some View {
        Section(content: { EmptyView() }, footer: {
            VStack {
                Text("Made with 🤘 by **[Nhon Nguyen](https://twitter.com/_ntnhon)**")
                Spacer()

                Text("App icon designed by **[Matt Stewart](https://twitter.com/nrthrndarkness)**")

                Spacer()

                Text("Version \(kVersionName) (Build \(kBuildNumber))")
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        })
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
