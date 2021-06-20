//
//  Theme.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 20/06/2021.
//

import SwiftUI

enum Theme: Int, CaseIterable {
    case `default` = 0, green/*, red, blue, orange, purple, yellow*/

    func primaryColor(for scheme: ColorScheme) -> Color {
        switch (scheme, self) {
        case (.light, .default), (.dark, .default):
            return Color(.sRGB, red: 140 / 255, green: 94 / 255, blue: 88 / 255, opacity: 1)
        case (.light, .green), (.dark, .green):
            return Color(.sRGB, red: 56 / 255, green: 176 / 255, blue: 0 / 255, opacity: 1)
        default: return .blue
        }
    }

    func secondaryColor(for scheme: ColorScheme) -> Color {
        switch (scheme, self) {
        case (.light, .default), (.dark, .default):
            return Color(.sRGB, red: 211 / 255, green: 171 / 255, blue: 158 / 255, opacity: 1)
        case (.light, .green), (.dark, .green):
            return Color(.sRGB, red: 112 / 255, green: 224 / 255, blue: 0 / 255, opacity: 1)
        default: return .blue
        }
    }
}
