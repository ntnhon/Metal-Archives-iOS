//
//  AlternateAppIcon.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 01/04/2024.
//

import Foundation

public enum AlternateAppIcon: Sendable {
    case primary
    case custom1
    case custom2
    case custom3
    case custom4
    case custom5
    case custom6

    public var iconName: String {
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

    public var value: String? {
        switch self {
        case .primary:
            nil
        default:
            iconName
        }
    }

    public static var customIcons: [Self] {
        [.custom1, .custom2, .custom3, .custom4, .custom5, .custom6]
    }

    public init(iconName: String?) {
        switch iconName {
        case "AppIcon-Custom1":
            self = .custom1
        case "AppIcon-Custom2":
            self = .custom2
        case "AppIcon-Custom3":
            self = .custom3
        case "AppIcon-Custom4":
            self = .custom4
        case "AppIcon-Custom5":
            self = .custom5
        case "AppIcon-Custom6":
            self = .custom6
        default:
            self = .primary
        }
    }
}
