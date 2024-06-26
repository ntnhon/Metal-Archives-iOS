//
//  RetryButton.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 05/10/2022.
//

import SwiftUI

struct RetryButton: View {
    @EnvironmentObject private var preferences: Preferences
    let onRetry: () async -> Void

    var body: some View {
        Button(action: {
            Task {
                await onRetry()
            }
        }, label: {
            Label("Retry", systemImage: "arrow.clockwise")
        })
        .foregroundColor(preferences.theme.primaryColor)
    }
}
