//
//  SFSafariView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 31/03/2024.
//

import Foundation
import SafariServices
import SwiftUI

// https://www.avanderlee.com/swiftui/sfsafariviewcontroller-open-webpages-in-app/
struct SFSafariView: UIViewControllerRepresentable {
    let url: URL
    var preferredBarTintColor: UIColor?
    var preferredControlTintColor: UIColor?
    var dismissButtonStyle: SFSafariViewController.DismissButtonStyle = .done

    func makeUIViewController(context _: Context) -> SFSafariViewController {
        let vc = SFSafariViewController(url: url)
        vc.preferredBarTintColor = preferredBarTintColor
        vc.preferredControlTintColor = preferredControlTintColor
        vc.dismissButtonStyle = dismissButtonStyle
        return vc
    }

    func updateUIViewController(_: SFSafariViewController,
                                context _: Context)
    {
        // No need to do anything
    }
}

struct SafariViewViewModifier: ViewModifier {
    @State private var urlToOpen: URL?
    var preferredBarTintColor: UIColor?
    var preferredControlTintColor: UIColor?
    var dismissButtonStyle: SFSafariViewController.DismissButtonStyle = .done

    func body(content: Content) -> some View {
        content
            .environment(\.openURL, OpenURLAction { url in
                // Catch any URLs that are about to be opened in an external browser.
                // Instead, handle them here and store the URL to reopen in our sheet.
                urlToOpen = url
                return .handled
            })
            .sheet(isPresented: $urlToOpen.mappedToBool()) {
                if let urlToOpen {
                    SFSafariView(url: urlToOpen,
                                 preferredBarTintColor: preferredBarTintColor,
                                 preferredControlTintColor: preferredControlTintColor,
                                 dismissButtonStyle: dismissButtonStyle)
                }
            }
    }
}

extension View {
    func openUrlsWithInAppSafari(controlTintColor: Color) -> some View {
        modifier(SafariViewViewModifier(preferredControlTintColor: UIColor(controlTintColor)))
    }
}
