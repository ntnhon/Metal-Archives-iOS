//
//  UtileFunctions.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 23/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import AttributedLib

enum AttributedStringType {
    case title, secondaryTitle
    
    var textAttributes: Attributes {
        switch self {
        case .title:
            return Attributes {
                return $0.foreground(color: Settings.currentTheme.titleColor)
                    .font(Settings.currentFontSize.titleFont)
            }
        case .secondaryTitle:
            return Attributes {
                return $0.foreground(color: Settings.currentTheme.secondaryTitleColor)
                    .font(Settings.currentFontSize.secondaryTitleFont)
            }
        }
    }
    
    var separatorAttributes: Attributes {
        switch self {
        case .title:
            return Attributes {
                return $0.foreground(color: Settings.currentTheme.bodyTextColor)
                    .font(Settings.currentFontSize.titleFont)
            }
        case .secondaryTitle:
            return Attributes {
                return $0.foreground(color: Settings.currentTheme.bodyTextColor)
                    .font(Settings.currentFontSize.secondaryTitleFont)
            }
        }
    }
}

func generateAttributedStringFromStrings(_ strings: [String], as type: AttributedStringType, withSeparator separator: String) -> NSAttributedString {
    
    let concatenatedAttrString = NSMutableAttributedString(string: "")
    for i in 0..<strings.count {
        let eachString = strings[i]
        concatenatedAttrString.append(eachString.at.attributed(with: type.textAttributes))
        if i != strings.count - 1 {
            concatenatedAttrString.append(separator.at.attributed(with: type.separatorAttributes))
        }
    }
    
    return concatenatedAttrString
}

let bodyTextAttributes = Attributes {
    return $0.foreground(color: Settings.currentTheme.bodyTextColor)
        .font(Settings.currentFontSize.bodyTextFont)
        .alignment(.justified)
}

let bigBodyTextAttributes = Attributes {
    return $0.foreground(color: Settings.currentTheme.bodyTextColor)
        .font(Settings.currentFontSize.titleFont)
        .alignment(.justified)
}

let hilightedBodyTextAttributes = Attributes {
    return $0.foreground(color: Settings.currentTheme.secondaryTitleColor)
        .font(Settings.currentFontSize.bodyTextFont)
        .alignment(.justified)
}

let boldBodyTextAttributes = Attributes {
    return $0.foreground(color: Settings.currentTheme.bodyTextColor)
        .font(Settings.currentFontSize.boldBodyTextFont)
        .alignment(.justified)
}

let secondaryTitleAttributes = Attributes {
    return $0.foreground(color: Settings.currentTheme.secondaryTitleColor)
        .font(Settings.currentFontSize.secondaryTitleFont)
        .alignment(.justified)
}

let titleAttributes = Attributes {
    return $0.foreground(color: Settings.currentTheme.titleColor)
        .font(Settings.currentFontSize.titleFont)
        .alignment(.justified)
}

let indentedBodyTextAttributes = Attributes {
    return $0.foreground(color: Settings.currentTheme.bodyTextColor)
        .font(Settings.currentFontSize.bodyTextFont)
        .alignment(.justified)
        .headIndent(20)
        .firstLineHeadIndent(20)
}
