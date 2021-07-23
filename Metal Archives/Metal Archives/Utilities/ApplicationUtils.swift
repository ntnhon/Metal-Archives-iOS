//
//  ApplicationUtils.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 23/07/2021.
//

import UIKit

enum ApplicationUtils {
    static func share(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(vc, animated: true)
    }

    static func popToRootView() {
        // swiftlint:disable:next first_where
        let window = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .map { $0 as? UIWindowScene }
            .compactMap { $0 }
            .first?.windows
            .filter { $0.isKeyWindow }
            .first
        let nvc = window?.rootViewController?.children.first as? UINavigationController
        nvc?.popToRootViewController(animated: true)
    }
}
