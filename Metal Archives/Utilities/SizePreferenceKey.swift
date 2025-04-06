//
//  SizePreferenceKey.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/07/2021.
//

import SwiftUI

struct SizePreferenceKey: PreferenceKey {
    static nonisolated(unsafe) var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct SizeModifier: ViewModifier {
    private var sizeView: some View {
        GeometryReader { geometry in
            Color.clear.preference(key: SizePreferenceKey.self, value: geometry.size)
        }
    }

    func body(content: Content) -> some View {
        content.background(sizeView)
    }
}
