//
//  LabelAdditionOrUpdate.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 26/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

class LabelAdditionOrUpdate: ThumbnailableObject {
    let name: String
    let status: LabelStatus
    let country: Country?
    let updatedDate: Date
    let user: User
    
    lazy var countryAndStatusAttributedString: NSAttributedString = {
        let countryNameAndEmojii = country?.nameAndEmoji ?? "Unknown country"
        let countryAndStatusString = "\(countryNameAndEmojii) • \(status.description)"
        let countryAndStatusAttributedString = NSMutableAttributedString(string: countryAndStatusString)
        
        countryAndStatusAttributedString.addAttributes([.foregroundColor: Settings.currentTheme.bodyTextColor, .font: Settings.currentFontSize.bodyTextFont], range: NSRange(countryAndStatusString.startIndex..., in: countryAndStatusString))
        
        if let countryNameAndEmojiiRange = countryAndStatusString.range(of: countryNameAndEmojii) {
            countryAndStatusAttributedString.addAttributes([.foregroundColor: Settings.currentTheme.secondaryTitleColor, .font: Settings.currentFontSize.secondaryTitleFont], range: NSRange(countryNameAndEmojiiRange, in: countryAndStatusString))
        }
        
        if let statusRange = countryAndStatusString.range(of: status.description) {
            countryAndStatusAttributedString.addAttributes([.foregroundColor: status.color, .font: Settings.currentFontSize.bodyTextFont], range: NSRange(statusRange, in: countryAndStatusString))
        }
        
        return countryAndStatusAttributedString
    }()
    
    lazy var formattedDateString: String = {
        let (value, unit) = updatedDate.distanceFromNow()
        let agoString = "(\(value) \(unit) ago)"
        
        return "\(defaultDateFormatter.string(from: updatedDate))" + " " + agoString
    }()
    
    /*
     Sample array:
     "May 13",
     "<a href="https://www.metal-archives.com/labels/Absolute_Label_Services/49818">Absolute Label Services</a>",
     "<span class="active">active</span>&nbsp;",
     "United Kingdom&nbsp;",
     "2019-05-13 08:37:42",
     "<a href="https://www.metal-archives.com/users/Starsmore" class="profileMenu">Starsmore</a>"
     */
    
    init?(from array: [String]) {
        guard array.count == 6 else { return nil }
        
        guard let urlSubstring = array[1].subString(after: #"href=""#, before: #"">"#, options: .caseInsensitive),
            let nameSubstring = array[1].subString(after: #"">"#, before: "</a>", options: .caseInsensitive) else { return nil }
        
        guard let statusSubstring = array[2].subString(after: #"">"#, before: "</span>", options: .caseInsensitive) else { return nil }
        
        guard let updatedDate = defaultDateFormatter.date(from: array[4]) else { return nil }
        
        guard let user = User(from: array[5]) else { return nil }
        
        let countryName = array[3].replacingOccurrences(of: "&nbsp;", with: "")
        self.country = Country(name: countryName)
        
        self.name = String(nameSubstring)
        self.status = LabelStatus(statusString: String(statusSubstring))
        self.updatedDate = updatedDate
        self.user = user
        super.init(urlString: String(urlSubstring), imageType: .label)
    }
}
