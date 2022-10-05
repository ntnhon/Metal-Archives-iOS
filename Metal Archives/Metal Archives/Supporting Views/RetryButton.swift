//
//  RetryButton.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 05/10/2022.
//

import SwiftUI

struct RetryButton: View {
    @EnvironmentObject private var preferences: Preferences
    let onRetry: () -> Void

    var body: some View {
        Button(action: onRetry) {
            Label("Retry", systemImage: "arrow.clockwise")
        }
        .foregroundColor(preferences.theme.primaryColor)
    }
}
