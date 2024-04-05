//
//  ColorExtensions.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/06/2021.
//

import SwiftUI

extension Color {
    static func byRating(_ rating: Int) -> Color {
        switch rating {
        case 0 ..< 25:
            BandStatus.splitUp.color
        case 25 ..< 50:
            BandStatus.onHold.color
        case 50 ..< 75:
            BandStatus.changedName.color
        default:
            BandStatus.active.color
        }
    }

    func lighter(by amount: CGFloat = 0.2) -> Self { Self(UIColor(self).lighter(by: amount)) }
    func darker(by amount: CGFloat = 0.2) -> Self { Self(UIColor(self).darker(by: amount)) }
}
