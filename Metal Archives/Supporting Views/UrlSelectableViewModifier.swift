//
//  UrlSelectableViewModifier.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 16/10/2022.
//

import SwiftUI

struct UrlSelectableViewModifier: ViewModifier {
    @EnvironmentObject private var preferences: Preferences
    @State private var selectedUrl: String?

    func body(content: Content) -> some View {
        content
            .betterSafariView(urlString: $selectedUrl,
                              tintColor: preferences.theme.primaryColor)
            .environment(\.selectedUrl, $selectedUrl)
    }
}

struct SelectedUrlKey: EnvironmentKey {
    static let defaultValue: Binding<String?> = .constant(nil)
}

extension EnvironmentValues {
    var selectedUrl: Binding<String?> {
        get { self[SelectedUrlKey.self] }
        set { self[SelectedUrlKey.self] = newValue }
    }
}
