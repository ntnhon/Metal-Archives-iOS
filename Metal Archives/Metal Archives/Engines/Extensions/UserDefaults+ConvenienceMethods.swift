//
//  UserDefaults+ConvenienceMethods.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

fileprivate let defaults = UserDefaults(suiteName: "group.info.nguyenthanhnhon.metal-archives-ios")!

extension UserDefaults {
    // MARK: - Init default values
    static func registerDefaultValues() {
        defaults.register(defaults: [themeKey: Theme.default.rawValue,
                                     thumbnailEnabledKey: true])
        
        defaults.register(defaults: [widgetSectionsKey: [WidgetSection.bandAdditions.rawValue, WidgetSection.bandUpdates.rawValue]])
        defaults.register(defaults: [numberOfSessionKey: 0])
        defaults.register(defaults: [didMakeAReviewKey: false])
    }
    
    // MARK: - Theme
    private static let themeKey = "ThemeKey"
    static func setTheme(_ theme: Theme) {
        defaults.set(theme.rawValue, forKey: themeKey)
    }
    
    static func selectedTheme() -> Theme {
        let themeRawValue = defaults.integer(forKey: themeKey)
        return Theme(rawValue: themeRawValue) ?? .default
    }
    
    // MARK: - Font Size
    private static let fontSizeKey = "FontSizeKey"
    static func setFontSize(_ fontSize: FontSize) {
        defaults.set(fontSize.rawValue, forKey: fontSizeKey)
    }
    
    static func selectedFontSize() -> FontSize {
        let fontSizeRawValue = defaults.integer(forKey: fontSizeKey)
        return FontSize(rawValue: fontSizeRawValue) ?? .default
    }
    
    // MARK: - Discography Type
    private static let discographyTypeKey = "DiscographyTypeKey"
    static func setDiscographyType(_ discographyType: DiscographyType) {
        defaults.set(discographyType.rawValue, forKey: discographyTypeKey)
    }
    
    static func selectedDiscographyType() -> DiscographyType {
        let discographyTypeRawValue = defaults.integer(forKey: discographyTypeKey)
        return DiscographyType(rawValue: discographyTypeRawValue) ?? .complete
    }
    
    // MARK: - Thumbnail
    private static let thumbnailEnabledKey = "ThumbnailEnabledKey"
    static func setThumbnailEnabled(_ enabled: Bool) {
        defaults.set(enabled, forKey: thumbnailEnabledKey)
    }
    
    static func thumbnailEnabled() -> Bool {
        return defaults.bool(forKey: thumbnailEnabledKey)
    }
    
    // MARK: - Widget
    private static let widgetSectionsKey = "WidgetSectionsKey"
    static func setWidgetSections(_ widgetSection: [WidgetSection]) {
        guard widgetSection.count == 1 || widgetSection.count == 2 else {
            assertionFailure("Widget sections count can only be 1 or 2.")
            return
        }
        
        var widgetSectionsRawValues: [Int] = []
        widgetSection.forEach({
            widgetSectionsRawValues.append($0.rawValue)
        })
        
        defaults.set(widgetSectionsRawValues, forKey: widgetSectionsKey)
    }
    
    static func choosenWidgetSections() -> [WidgetSection] {
        guard let widgetSectionsRawValues = defaults.array(forKey: widgetSectionsKey) as? [Int] else {
            UserDefaults.registerDefaultValues()
            return UserDefaults.choosenWidgetSections()
        }
        
        return widgetSectionsRawValues.map({ (rawValue) -> WidgetSection in
            return WidgetSection(rawValue: rawValue) ?? .bandUpdates
        })
    }
    
    // MARK: - Review
    private static let numberOfSessionKey = "NumberOfSessionKey"
    static func numberOfSessions() -> Int {
        return defaults.integer(forKey: numberOfSessionKey)
    }
    
    static func increaseNumberOfSessions() {
        let numberOfSessions = defaults.integer(forKey: numberOfSessionKey)
        defaults.set(numberOfSessions + 1, forKey: numberOfSessionKey)
    }
    
    private static let didMakeAReviewKey = "DidMakeAReviewKey"
    static func didMakeAReview() -> Bool {
        return defaults.bool(forKey: didMakeAReviewKey)
    }
    
    static func setDidMakeAReview() {
        defaults.set(true, forKey: didMakeAReviewKey)
    }
    
    // MARK: - New version
    static func shouldAlertNewVersion() -> Bool {
        if let `appVersion` = appVersion {
            return !defaults.bool(forKey: appVersion)
        }
        
        return false
    }
    
    static func markDidAlertNewVersion() {
        if let `appVersion` = appVersion {
            defaults.set(true, forKey: appVersion)
        }
    }
    
    // MARK: - Thumbnail
    private static let customGenresKey = "CustomGenresKey"
    
    static func setCustomGenres(_ customGenres: [String]) {
        defaults.set(customGenres, forKey: customGenresKey)
    }

    static func customGenres() -> [String] {
        if let customGenres = defaults.object(forKey: customGenresKey) as? [String] {
            return customGenres
        }
        
        return []
    }
}
