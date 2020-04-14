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
    static let numberOfRetries = 5
    static let thumbnailHeight: CGFloat = {
        let preferredHeight = screenWidth / 5
        let maxHeight: CGFloat = 72.0
        if preferredHeight > maxHeight {
            return maxHeight
        }
        return preferredHeight
    }()
    
    // CollectionView Settings
    static let numberOfNewsItemPerRow = 1
    static let newsCollectionViewCellHeight: CGFloat = ceil(screenHeight / 6)
    static let numberOfGeneralItemPerRow = 3
    static let generalCollectionViewCellHeight: CGFloat = {
        switch currentFontSize! {
        case .default: return ceil(screenHeight / 9)
        case .medium: return ceil(screenHeight / 8)
        case .large: return ceil(screenHeight / 7)
        }
    }()
    static let upcomingAlbumCollectionViewCellHeight: CGFloat = {
        switch currentFontSize! {
        case .default: return ceil(screenHeight / 8)
        case .medium: return ceil(screenHeight / 7)
        case .large: return ceil(screenHeight / 6)
        }
    }()

    static let collectionViewItemSpacing: CGFloat = 8
    static let collectionViewContentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    static let collectionViewCellWidth: CGFloat = screenWidth - collectionViewContentInset.left - collectionViewContentInset.right - collectionViewItemSpacing
    
    static var currentTheme: Theme!
    static var currentFontSize: FontSize!
    static var thumbnailEnabled: Bool!
    
    static let strechyLogoImageViewHeight: CGFloat = screenHeight / 4
    static let bandPhotoImageViewHeight: CGFloat = screenHeight / 8
    
    static let spaceBetweenInfoAndDetailSection: CGFloat = 20
    
    static let animationDuration: TimeInterval = 0.35
    
    static let historyMaxCapacity = 100
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
    
    var largeMetalTitleFont: UIFont {
        switch self {
        case .default:
            return UIFont(name: "NewRocker-Regular", size: 25) ?? largeTitleFont
        case .medium:
            return UIFont(name: "NewRocker-Regular", size: 27) ?? largeTitleFont
        case .large:
            return UIFont(name: "NewRocker-Regular", size: 29) ?? largeTitleFont
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
    
    var boldBodyTextFont: UIFont {
        switch self {
        case .default:
            return UIFont.systemFont(ofSize: 14, weight: .bold)
        case .medium:
            return UIFont.systemFont(ofSize: 16, weight: .bold)
        case .large:
            return UIFont.systemFont(ofSize: 18, weight: .bold)
        }
    }
    
    var metalBodyTextFont: UIFont {
        switch self {
        case .default:
            return UIFont(name: "NewRocker-Regular", size: 14) ?? bodyTextFont
        case .medium:
            return UIFont(name: "NewRocker-Regular", size: 16) ?? bodyTextFont
        case .large:
            return UIFont(name: "NewRocker-Regular", size: 18) ?? bodyTextFont
        }
    }
    
    var italicBodyTextFont: UIFont {
        switch self {
        case .default:
            return UIFont.italicSystemFont(ofSize: 14)
        case .medium:
            return UIFont.italicSystemFont(ofSize: 16)
        case .large:
            return UIFont.italicSystemFont(ofSize: 18)
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
    
    var statusBarStyle: UIStatusBarStyle {
        switch self {
        case .default, .unicorn: return .lightContent
        case .light, .vintage: return .default
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
    
    var collectionViewSeparatorColor: UIColor {
        return bodyTextColor.withAlphaComponent(0.5)
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

 // MARK: - User ranking color
extension Theme {
    var webmasterColor: UIColor {
        return .systemRed
    }
    
    var metalGodColor: UIColor {
        return UIColor("#F26236")
    }
    
    var metalLordColor: UIColor {
        return UIColor("#2F294F")
    }
    
    var metalDemonColor: UIColor {
        return UIColor("#319A8C")
    }
    
    var metalKnightColor: UIColor {
        return UIColor("#B74E8C")
    }
    
    var dishonourablyDischargedColor: UIColor {
        return UIColor("#143E5A")
    }
    
    var metalFreakColor: UIColor {
        return UIColor("#EF6061")
    }
    
    var veteranColor: UIColor {
        return UIColor("#F1A302")
    }
    
    var metalheadColor: UIColor {
        return UIColor("#7B69F5")
    }
}
