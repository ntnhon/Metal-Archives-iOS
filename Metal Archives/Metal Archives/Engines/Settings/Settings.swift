//
//  Settings.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 16/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import UIKit
import UIColor_Hex_Swift

struct Settings {
    static let shortListDisplayCount = 5
    static let numberOfRetries = 5
    static let segmentedHeaderHeight: CGFloat = 35
    static let thumbnailHeight: CGFloat = {
        let preferredHeight = screenWith/5
        let maxHeight: CGFloat = 72.0
        if preferredHeight > maxHeight {
            return maxHeight
        }
        return preferredHeight
    }()
    static var currentTheme: Theme!
    static var currentFontSize: FontSize!
    static var thumbnailEnabled: Bool!
}

enum FontSize: Int, CustomStringConvertible {
    case `default` = 0, medium, large
    
    var description: String {
        switch self {
        case .default: return "Default"
        case .medium: return "Medium"
        case .large: return "Large"
        }
    }
    
    var largeTitleFont: UIFont {
        switch self {
        case .default:
            return UIFont.systemFont(ofSize: 25, weight: .bold)
        case .medium:
            return UIFont.systemFont(ofSize: 27, weight: .bold)
        case .large:
            return UIFont.systemFont(ofSize: 29, weight: .bold)
        }
    }
    
    var titleFont: UIFont {
        switch self {
        case .default:
            return UIFont.systemFont(ofSize: 17, weight: .semibold)
        case .medium:
            return UIFont.systemFont(ofSize: 19, weight: .semibold)
        case .large:
            return UIFont.systemFont(ofSize: 21, weight: .semibold)
        }
    }
    
    var secondaryTitleFont: UIFont {
        switch self {
        case .default:
            return UIFont.systemFont(ofSize: 15, weight: .medium)
        case .medium:
            return UIFont.systemFont(ofSize: 17, weight: .medium)
        case .large:
            return UIFont.systemFont(ofSize: 19, weight: .medium)
        }
    }
    
    var bodyTextFont: UIFont {
        switch self {
        case .default:
            return UIFont.systemFont(ofSize: 14, weight: .regular)
        case .medium:
            return UIFont.systemFont(ofSize: 16, weight: .regular)
        case .large:
            return UIFont.systemFont(ofSize: 18, weight: .regular)
        }
    }
    
    var reviewTitleFont: UIFont {
        switch self {
        case .default:
            return UIFont.systemFont(ofSize: 17, weight: .bold)
        case .medium:
            return UIFont.systemFont(ofSize: 19, weight: .bold)
        case .large:
            return UIFont.systemFont(ofSize: 21, weight: .bold)
        }
    }
    
    var tertiaryFont: UIFont {
        switch self {
        case .default:
            return UIFont.systemFont(ofSize: 13, weight: .regular)
        case .medium:
            return UIFont.systemFont(ofSize: 15, weight: .regular)
        case .large:
            return UIFont.systemFont(ofSize: 17, weight: .regular)
        }
    }
}

enum Theme: Int, CustomStringConvertible {
    case `default` = 0, light, vintage, unicorn
    
    var description: String {
        switch self {
        case .default: return "Default"
        case .light: return "Light"
        case .vintage: return "Vintage"
        case .unicorn: return "Unicorn"
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .default: return .black
        case .light: return .white
        case .vintage: return UIColor("#EDECD0")
        case .unicorn: return UIColor("#BCFFBC")
        }
    }
    
    var titleColor: UIColor {
        switch self {
        case .default: return UIColor("#8C5E58")
        case .light: return UIColor("#303030")
        case .vintage: return UIColor("#DE946D")
        case .unicorn: return UIColor("#C9B1FF")
        }
    }
    
    var secondaryTitleColor: UIColor {
        switch self {
        case .default: return UIColor("#D3AB9E")
        case .light: return UIColor("#B2B2B2")
        case .vintage: return UIColor("#C9A655")
        case .unicorn: return UIColor("#FFCAF2")
        }
    }
    
    var menuTitleColor: UIColor {
        switch self {
        case .default: return UIColor("#ACA096")
        case .light: return UIColor.black
        case .vintage: return UIColor("#DE946D")
        case .unicorn: return UIColor("#FFB2B1")
        }
    }
    
    var leftMenuOptionBackgroundColor: UIColor {
        switch self {
        case .default: return UIColor("#321918")
        case .light: return UIColor("#EFEFEF")
        case .vintage: return UIColor("#BEC2A1")
        case .unicorn: return UIColor("#A2EDFF")
        }
    }
    
    var bodyTextColor: UIColor {
        switch self {
        case .default: return .white
        case .light: return UIColor("#505050")
        case .vintage: return UIColor("#676863")
        case .unicorn: return UIColor("#C9B1FF")
        }
    }
    
    var slideMenuControllerOpacityBackgroundColor: UIColor {
        return .white
    }
    
    var tableViewCellSelectionColor: UIColor {
        switch self {
        case .default: return UIColor.white.withAlphaComponent(0.3)
        case .light: return UIColor.black.withAlphaComponent(0.3)
        case .vintage: return UIColor.white.withAlphaComponent(0.3)
        case .unicorn: return UIColor.white.withAlphaComponent(0.3)
        }
    }
    
    var activeStatusColor: UIColor {
        switch self {
        case .default: return UIColor("#87FF65")
        default: return UIColor("#65BF4C")
        }
    }
    
    var onHoldStatusColor: UIColor {
        switch self {
        case .default: return UIColor("#FFF275")
        case .light: return UIColor("#EEE833")
        case .vintage: return UIColor("#BFB558")
        case .unicorn: return UIColor("#EEE833")
        }
    }
    
    var splitUpStatusColor: UIColor {
        switch self {
        case .default: return UIColor("#FF3C38")
        default: return UIColor("#E53632")
        }
    }
    
    var closedStatusColor: UIColor {
        return self.splitUpStatusColor
    }
    
    var changedNameStatusColor: UIColor {
        switch self {
        case .default: return UIColor("#48ACF0")
        default: return UIColor("#409AD6")
        }
    }
    
    var unknownStatusColor: UIColor {
        switch self {
        case .default: return UIColor("#FF8C42")
        default: return UIColor("#E57E3B")
        }
    }
    
    var disputedStatusColor: UIColor {
        switch self {
        case .default: return UIColor("#B200ED")
        default: return UIColor("#9F00D3")
        }
    }
    
    var tableViewBackgroundColor: UIColor {
        return leftMenuOptionBackgroundColor
    }
    
    var tableViewSeparatorColor: UIColor {
        return secondaryTitleColor
    }
    
    var iconTintColor: UIColor {
        return secondaryTitleColor
    }
    
    
    
    var reviewTitleColor: UIColor {
        return bodyTextColor
    }
    
    
    var activityIndicatorStyle: UIActivityIndicatorView.Style {
        switch self {
        case .default: return .white
        default: return .gray
        }
    }
    
    var segmentNormalTextColor: UIColor {
        switch self {
        case .default: return self.backgroundColor
        default: return self.bodyTextColor
        }
    }
    
    var segmentSelectedTextColor: UIColor {
        switch self {
        case .default: return self.bodyTextColor
        default: return self.backgroundColor
        }
    }
    
    var imageViewBackgroundColor: UIColor {
        switch self {
        case .light:
            return self.bodyTextColor.withAlphaComponent(0.3)
        default: return self.backgroundColor
        }
    }
}
