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
        case 0..<25: return BandStatus.splitUp.color
        case 25..<50: return BandStatus.onHold.color
        case 50..<75: return BandStatus.changedName.color
        default: return BandStatus.active.color
        }
    }
}
