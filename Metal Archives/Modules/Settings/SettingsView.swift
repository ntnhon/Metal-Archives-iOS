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
    @Environment(\.selectedUrl) private var selectedUrl

    @State private var showAboutSheet = false
    @State private var showSupportSheet = false
    @State private var showThemePreview = false

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
    }

    private var generalSection: some View {
        Section(header: Text("General")) {
            NavigationLink(destination: HomeSectionOrderView()) {
                Text("Home section order")
            }

            Toggle("Show thumbnails", isOn: $preferences.showThumbnails)

            Picker("Default discography mode", selection: $preferences.discographyMode) {
                ForEach(DiscographyMode.allCases, id: \.self) { mode in
                    Text(mode.description)
                }
            }

            Picker("Default order by date", selection: $preferences.dateOrder) {
                ForEach(Order.allCases, id: \.self) { order in
                    Text(order.title)
                }
            }

            Toggle("Haptic effect", isOn: $preferences.useHaptic)
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
                   UIApplication.shared.canOpenURL(url)
                {
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
                selectedUrl.wrappedValue = "https://www.metal-archives.com/"
            }, label: {
                Label("Website", systemImage: "link")
                    .foregroundColor(.primary)
            })

            Button(action: {
                selectedUrl.wrappedValue = "https://www.metal-archives.com/board/"
            }, label: {
                Label("Forum", systemImage: "globe")
                    .foregroundColor(.primary)
            })
        }
    }

    private var mobileAppLinksSection: some View {
        Section(header: Text("Mobile Application Links"),
                footer: Text("For crashes, bug reports & feature requests related to this iOS app"))
        {
            // Twitter
            Button(action: {
                selectedUrl.wrappedValue = "https://twitter.com/ma_mobile_app"
            }, label: {
                Label(title: {
                    Text("Twitter")
                }, icon: {
                    Image("Twitter")
                        .resizable()
                        .frame(width: 18, height: 18, alignment: .leading)
                })
            })
            .buttonStyle(.plain)

            // Facebook
            Button(action: {
                selectedUrl.wrappedValue = "https://www.facebook.com/MetalArchivesMobileApp"
            }, label: {
                Label(title: {
                    Text("Facebook")
                }, icon: {
                    Image("Facebook")
                        .resizable()
                        .frame(width: 18, height: 18, alignment: .leading)
                })
            })
            .buttonStyle(.plain)

            // Github
            Button(action: {
                selectedUrl.wrappedValue = "https://github.com/ntnhon/Metal-Archives-iOS"
            }, label: {
                Label(title: {
                    Text("Github")
                }, icon: {
                    Image("Github")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.primary)
                        .frame(width: 18, height: 18, alignment: .leading)
                })
            })
            .buttonStyle(.plain)

            // Email
            Button(action: {
                if let url = URL(string: "mailto:hi@nguyenthanhnhon.info"),
                   UIApplication.shared.canOpenURL(url)
                {
                    UIApplication.shared.open(url)
                }
            }, label: {
                Label("Email", systemImage: "envelope.fill")
            })
            .buttonStyle(.plain)
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
