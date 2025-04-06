//
//  SKStoreReviewControllerExtensions.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 20/06/2021.
//

import StoreKit

@MainActor
extension SKStoreReviewController {
    static func askForReview() {
        let scenes = UIApplication.shared.connectedScenes
        if let scene = scenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}
