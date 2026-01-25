//
//  SnappingScrollView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 18/01/2026.
//

import SwiftUI

struct SnappingScrollView<Content: View, Item: Any, ID: Hashable>: View {
    let items: [Item]
    let id: KeyPath<Item, ID>
    let content: (Item) -> Content

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(items, id: id) { item in
                    content(item)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .contentMargins(.horizontal, 24, for: .scrollContent)
    }
}
