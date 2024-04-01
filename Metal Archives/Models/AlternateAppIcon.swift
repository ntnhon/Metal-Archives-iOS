//
//  AlternateAppIcon.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 01/04/2024.
//

import Foundation

enum AlternateAppIcon {
    case primary
    case guitar1
    case guitar2
    case guitar3
    case guitar4
    case guitar5
    case guitar6

    var iconName: String? {
        switch self {
        case .primary:
            nil
        case .guitar1:
            "AppIcon-Guitar1"
        case .guitar2:
            "AppIcon-Guitar2"
        case .guitar3:
            "AppIcon-Guitar3"
        case .guitar4:
            "AppIcon-Guitar4"
        case .guitar5:
            "AppIcon-Guitar5"
        case .guitar6:
            "AppIcon-Guitar6"
        }
    }
}
