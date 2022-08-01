//
//  BetterSafariViewModifier.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 01/08/2022.
//

import BetterSafariView
import SwiftUI

struct BetterSafariViewModifier: ViewModifier {
    @Binding var urlString: String?

    func body(content: Content) -> some View {
        let showingSafariView = Binding<Bool>(get: {
            if let urlString = urlString, URL(string: urlString) != nil {
                return true
            }
            return false
        }, set: { isShowing in
            if !isShowing {
                urlString = nil
            }
        })

        content
            .safariView(isPresented: showingSafariView) {
                // swiftlint:disable:next force_unwrapping
                SafariView(url: URL(string: urlString ?? "")!)
            }
    }
}

extension View {
    func betterSafariView(urlString: Binding<String?>) -> some View {
        modifier(BetterSafariViewModifier(urlString: urlString))
    }
}
