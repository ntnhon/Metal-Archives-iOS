//
//  OpenReviewOnAppStore.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 25/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import FirebaseAnalytics

func openReviewOnAppStore() {
    let appStoreURLString = "https://itunes.apple.com/app/id1074038930?action=write-review"
    UIApplication.shared.open(URL(string: appStoreURLString)!, options: [:]) { (finished) in
        Analytics.logEvent(AnalyticsEvent.MadeAReview, parameters: nil)
    }
}
