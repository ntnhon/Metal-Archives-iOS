//
//  SettingsViewModel.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/06/2021.
//

import Foundation

final class SettingsViewModel {
    let versionName: String
    let buildNumber: String

    init() {
        self.versionName = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "?"
        self.buildNumber = (Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? "?"
    }
}
