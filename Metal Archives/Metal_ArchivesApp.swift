//
//  Metal_ArchivesApp.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 20/05/2021.
//

import SwiftUI

private let kShownWhatsNewVersion = "ShownWhatsNewVersion"

@main
struct Metal_ArchivesApp: App {
    @StateObject private var preferences = Preferences()
    @State private var showingWhatsNew = false
    let userDefaults: UserDefaults = .standard

    var body: some Scene {
        WindowGroup {
            RootView()
                .modifier(PhotoSelectableViewModifier())
                .openUrlsWithInAppSafari(controlTintColor: preferences.theme.primaryColor)
                .modifier(ToastViewModifier())
                .environmentObject(preferences)
                .preferredColorScheme(.dark)
                .sheet(isPresented: $showingWhatsNew) {
                    WhatsNewView(version: .current, showVersion: false)
                        .environmentObject(preferences)
                }
                .onAppear(perform: showWhatsNewIfApplicable)
        }
    }
}

private extension Metal_ArchivesApp {
    func showWhatsNewIfApplicable() {
        guard userDefaults.string(forKey: kShownWhatsNewVersion) != AppVersion.current.name else {
            return
        }
        userDefaults.setValue(AppVersion.current.name, forKey: kShownWhatsNewVersion)
        showingWhatsNew = true
    }
}
