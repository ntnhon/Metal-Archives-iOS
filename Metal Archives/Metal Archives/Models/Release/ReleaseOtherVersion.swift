//
//  ReleaseOtherVersion.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 06/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class ReleaseOtherVersion {
    let id: String
    let urlString: String
    let dateString: String
    let labelName: String
    let catalogID: String?
    let additionalDetail: String //Ex: "Unofficial"
    let format: String
    let description: String?
    
    lazy var dateWithAdditionalDetailAndLabelAttributedString: NSAttributedString = {
        let dateAndLabelNameString = "\(dateString)\(additionalDetail) • \(labelName)"
        let dateAndLabelNameAttributedString = NSMutableAttributedString(string: dateAndLabelNameString)
        dateAndLabelNameAttributedString.addAttributes([.foregroundColor: Settings.currentTheme.bodyTextColor, .font: Settings.currentFontSize.bodyTextFont], range: NSRange(dateAndLabelNameString.startIndex..., in: dateAndLabelNameString))
        
        if let dateStringRange = dateAndLabelNameString.range(of: dateString) {
            dateAndLabelNameAttributedString.addAttributes([.foregroundColor: Settings.currentTheme.titleColor], range: NSRange(dateStringRange, in: dateAndLabelNameString))
        }
        
        if let unofficialStringRange = dateAndLabelNameString.range(of: "Unofficial") {
            dateAndLabelNameAttributedString.addAttributes([.foregroundColor: Settings.currentTheme.splitUpStatusColor], range: NSRange(unofficialStringRange, in: dateAndLabelNameString))
        }
        
        return dateAndLabelNameAttributedString
    }()
    
    lazy var formatAndCatalogIDAttributedString: NSAttributedString = {
        var formatAndCatalogIDString = ""
        if let catalogID = catalogID {
            formatAndCatalogIDString = "\(format) • \(catalogID)"
        } else {
            formatAndCatalogIDString = format
        }
        
        let formatAndCatalogIDAttributedString = NSMutableAttributedString(string: formatAndCatalogIDString)
        
        formatAndCatalogIDAttributedString.addAttributes([.foregroundColor: Settings.currentTheme.bodyTextColor, .font: Settings.currentFontSize.bodyTextFont], range: NSRange(formatAndCatalogIDString.startIndex..., in: formatAndCatalogIDString))
        
        if let formatRange = formatAndCatalogIDString.range(of: format) {
            formatAndCatalogIDAttributedString.addAttributes([.foregroundColor: Settings.currentTheme.secondaryTitleColor], range: NSRange(formatRange, in: formatAndCatalogIDString))
        }
        
        return formatAndCatalogIDAttributedString
    }()
    
    init?(urlString: String, dateString: String, additionalDetail: String, labelName: String, catalogID: String, format: String, description: String) {
        guard let id = urlString.components(separatedBy: "/").last else {
            return nil
        }
        
        self.id = id
        self.urlString = urlString
        self.dateString = dateString
        self.additionalDetail = additionalDetail
        self.labelName = labelName
        
        if catalogID == "" {
            self.catalogID = nil
        } else {
            self.catalogID = catalogID
        }
        
        self.format = format
        
        if description == "" {
            self.description = nil
        } else {
            self.description = description
        }
    }
}
