//
//  Theme.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 20/06/2021.
//

import SwiftUI

enum Theme: Int, CaseIterable {
    case `default` = 0, green, red, blue, orange, violet, pink

    var primaryColor: Color {
        switch self {
        case .default:
            return Color(.sRGB, red: 140 / 255, green: 94 / 255, blue: 88 / 255, opacity: 1)
        case .green:
            return Color(.sRGB, red: 45 / 255, green: 198 / 255, blue: 83 / 255, opacity: 1)
        case .red:
            return Color(.sRGB, red: 240 / 255, green: 60 / 255, blue: 20 / 255, opacity: 1)
        case .blue:
            return Color(.sRGB, red: 0 / 255, green: 150 / 255, blue: 199 / 255, opacity: 1)
        case .orange:
            return Color(.sRGB, red: 255 / 255, green: 149 / 255, blue: 0 / 255, opacity: 1)
        case .violet:
            return Color(.sRGB, red: 129 / 255, green: 90 / 255, blue: 192 / 255, opacity: 1)
        case .pink:
            return Color(.sRGB, red: 255 / 255, green: 153 / 255, blue: 172 / 255, opacity: 1)
        }
    }

    var secondaryColor: Color {
        switch self {
        case .default:
            return Color(.sRGB, red: 211 / 255, green: 171 / 255, blue: 158 / 255, opacity: 1)
        case .green:
            return Color(.sRGB, red: 183 / 255, green: 239 / 255, blue: 197 / 255, opacity: 1)
        case .red:
            return Color(.sRGB, red: 255 / 255, green: 110 / 255, blue: 80 / 255, opacity: 1)
        case .blue:
            return Color(.sRGB, red: 144 / 255, green: 224 / 255, blue: 239 / 255, opacity: 1)
        case .orange:
            return Color(.sRGB, red: 255 / 255, green: 208 / 255, blue: 0 / 255, opacity: 1)
        case .violet:
            return Color(.sRGB, red: 177 / 255, green: 133 / 255, blue: 219 / 255, opacity: 1)
        case .pink:
            return Color(.sRGB, red: 249 / 255, green: 190 / 255, blue: 199 / 255, opacity: 1)
        }
    }
}
