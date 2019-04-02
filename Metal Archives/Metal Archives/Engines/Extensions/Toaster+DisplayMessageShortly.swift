//
//  Toaster+DisplayMessageShortly.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 23/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import Toaster

extension Toast {
    static func displayMessageShortly(_ message: String) {
        ToastCenter.default.cancelAll()
        Toast(text: message, duration: Delay.short).show()
    }

    static func displayBlockedMessageWithDelay() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            ToastCenter.default.cancelAll()
            Toast(text: blockedMessage, duration: 4).show()
        }
    }
}
