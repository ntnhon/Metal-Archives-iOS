//
//  AlternateAppIcon.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 01/04/2024.
//

import Foundation

enum AlternateAppIcon {
    case primary
    case custom1
    case custom2
    case custom3
    case custom4
    case custom5
    case custom6

    var iconName: String {
        switch self {
        case .primary:
            "AppIcon"
        case .custom1:
            "AppIcon-Custom1"
        case .custom2:
            "AppIcon-Custom2"
        case .custom3:
            "AppIcon-Custom3"
        case .custom4:
            "AppIcon-Custom4"
        case .custom5:
            "AppIcon-Custom5"
        case .custom6:
            "AppIcon-Custom6"
        }
    }

    var value: String? {
        switch self {
        case .primary:
            nil
        default:
            iconName
        }
    }
}
