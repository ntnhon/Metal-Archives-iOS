//
//  Metal_ArchivesApp.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 20/05/2021.
//

import SwiftUI

@main
struct Metal_ArchivesApp: App {
    let apiService = APIService()
    var body: some Scene {
        WindowGroup {
            RootView(apiService: apiService)
                .modifier(PhotoSelectableViewModifier())
                .environmentObject(Preferences())
                .preferredColorScheme(.dark)
        }
    }
}
