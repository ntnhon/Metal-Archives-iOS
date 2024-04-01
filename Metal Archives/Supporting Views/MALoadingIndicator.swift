//
//  MALoadingIndicator.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 01/04/2024.
//

import SwiftfulLoadingIndicators
import SwiftUI

struct MALoadingIndicator: View {
    @EnvironmentObject private var preferences: Preferences

    var body: some View {
        LoadingIndicator(animation: preferences.loadingAnimation, color: .secondary)
    }
}
