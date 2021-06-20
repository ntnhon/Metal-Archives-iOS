//
//  Theme.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 20/06/2021.
//

import SwiftUI

enum Theme: Int, CaseIterable {
    case `default` = 0, green, red, blue/*, orange, purple, yellow*/

    func primaryColor(for scheme: ColorScheme) -> Color {
        switch (scheme, self) {
        case (.light, .default):
            return Color(.sRGB, red: 114 / 255, green: 77 / 255, blue: 72 / 255, opacity: 1)
        case (.dark, .default):
            return Color(.sRGB, red: 140 / 255, green: 94 / 255, blue: 88 / 255, opacity: 1)
        case (.light, .green):
            return Color(.sRGB, red: 32 / 255, green: 139 / 255, blue: 58 / 255, opacity: 1)
        case (.dark, .green):
            return Color(.sRGB, red: 45 / 255, green: 198 / 255, blue: 83 / 255, opacity: 1)
        case (.light, .red):
            return Color(.sRGB, red: 255 / 255, green: 30 / 255, blue: 30 / 255, opacity: 1)
        case (.dark, .red):
            return Color(.sRGB, red: 240 / 255, green: 60 / 255, blue: 20 / 255, opacity: 1)
        case (.light, .blue):
            return Color(.sRGB, red: 0 / 255, green: 119 / 255, blue: 182 / 255, opacity: 1)
        case (.dark, .blue):
            return Color(.sRGB, red: 0 / 255, green: 150 / 255, blue: 199 / 255, opacity: 1)
        default: return .blue
        }
    }

    func secondaryColor(for scheme: ColorScheme) -> Color {
        switch (scheme, self) {
        case (.light, .default):
            return Color(.sRGB, red: 175 / 255, green: 135 / 255, blue: 120 / 255, opacity: 1)
        case (.dark, .default):
            return Color(.sRGB, red: 211 / 255, green: 171 / 255, blue: 158 / 255, opacity: 1)
        case (.light, .green):
            return Color(.sRGB, red: 74 / 255, green: 214 / 255, blue: 109 / 255, opacity: 1)
        case (.dark, .green):
            return Color(.sRGB, red: 183 / 255, green: 239 / 255, blue: 197 / 255, opacity: 1)
        case (.light, .red):
            return Color(.sRGB, red: 255 / 255, green: 80 / 255, blue: 80 / 255, opacity: 1)
        case (.dark, .red):
            return Color(.sRGB, red: 255 / 255, green: 110 / 255, blue: 80 / 255, opacity: 1)
        case (.light, .blue):
            return Color(.sRGB, red: 0 / 255, green: 180 / 255, blue: 216 / 255, opacity: 1)
        case (.dark, .blue):
            return Color(.sRGB, red: 144 / 255, green: 224 / 255, blue: 239 / 255, opacity: 1)
        default: return .blue
        }
    }
}
