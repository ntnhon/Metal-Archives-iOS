//
//  NotificationName.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//
import Foundation

extension Notification.Name {
    static let InternetIsReachable = Notification.Name("InternetIsReachable")
    static let InternetIsUnreachable = Notification.Name("InternetIsUnreachable")
    static let OpenSearchModule = Notification.Name("OpenSearchModule")
    static let ShowRandomBand = Notification.Name("ShowRandomBand")
    static let ShowBandDetail = Notification.Name("ShowBandDetail")
    static let ShowReleaseDetail = Notification.Name("ShowReleaseDetail")
    static let ShowReviewDetail = Notification.Name("ShowReviewDetail")
    static let AskForReview = Notification.Name("AskForReview")
}
