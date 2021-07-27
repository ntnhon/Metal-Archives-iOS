//
//  ExpandableText.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/07/2021.
//

import SwiftUI

struct ExpandableText: View {
    @State private var noLimit = false
    let content: String

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Text(content)
                .font(.callout)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(noLimit ? nil : 6)
                .onTapGesture {
                    withAnimation {
                        noLimit.toggle()
                    }
                }

            if !noLimit {
                HStack {
                    Text("...")
                    Text("See more")
                        .foregroundColor(.secondary)
                }
                .font(.callout)
                .background(Color(.systemBackground))
            }
        }
    }
}

struct ExpandableText_Previews: PreviewProvider {
    // swiftlint:disable line_length
    static var previews: some View {
        ExpandableText(content: """
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
            """)
    }
}
