//
//  OffsetAwareScrollView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 30/07/2022.
//

import SwiftUI

// https://betterprogramming.pub/swiftui-calculate-scroll-offset-in-scrollviews-c3b121f0b0dc
struct OffsetAwareScrollView<T: View>: View {
    let axes: Axis.Set
    let showsIndicator: Bool
    let onOffsetChanged: (CGPoint) -> Void
    let content: T

    init(axes: Axis.Set = .vertical,
         showsIndicator: Bool = true,
         onOffsetChanged: @escaping (CGPoint) -> Void = { _ in },
         @ViewBuilder content: () -> T
    ) {
        self.axes = axes
        self.showsIndicator = showsIndicator
        self.onOffsetChanged = onOffsetChanged
        self.content = content()
    }

    var body: some View {
        ScrollView(axes, showsIndicators: showsIndicator) {
            GeometryReader { proxy in
                Color.clear.preference(
                    key: OffsetPreferenceKey.self,
                    value: proxy.frame(
                        in: .named("ScrollViewOrigin")
                    ).origin
                )
            }
            .frame(width: 0, height: 0)
            content
        }
        .coordinateSpace(name: "ScrollViewOrigin")
        .onPreferenceChange(OffsetPreferenceKey.self,
                            perform: onOffsetChanged)
    }
}

private struct OffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero

    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {}
}
