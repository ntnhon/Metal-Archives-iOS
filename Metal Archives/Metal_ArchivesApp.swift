//
//  Metal_ArchivesApp.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 20/05/2021.
//

import SwiftUI

@main
struct Metal_ArchivesApp: App {
    @StateObject private var preferences = Preferences()

    var body: some Scene {
        WindowGroup {
            RootView()
                .modifier(PhotoSelectableViewModifier())
                .openUrlsWithInAppSafari(controlTintColor: preferences.theme.primaryColor)
                .modifier(ToastViewModifier())
                .environmentObject(preferences)
                .preferredColorScheme(.dark)
        }
    }
}
