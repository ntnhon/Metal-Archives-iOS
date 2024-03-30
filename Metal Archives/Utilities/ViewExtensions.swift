//
//  ViewExtensions.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 25/06/2021.
//

import SwiftUI
import UIKit

#if canImport(UIKit)
    extension View {
        func hideKeyboard() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                            to: nil,
                                            from: nil,
                                            for: nil)
        }
    }
#endif
