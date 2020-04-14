//
//  BandAdditionOrUpdate.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 12/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

class BandAdditionOrUpdate: ThumbnailableObject {
    let name: String
    let country: Country
    let genre: String
    let updatedDateAndTimeString: String
    let user: UserLite
    
    lazy var countryAndDateAttributedString: NSAttributedString = {
        let countryAndDateString = "\(country.nameAndEmoji) • \(updatedDateAndTimeString)"
        let countryAndDateAttributedString = NSMutableAttributedString(string: countryAndDateString)
        
        countryAndDateAttributedString.addAttributes([.foregroundColor: Settings.currentTheme.bodyTextColor, .font: Settings.currentFontSize.bodyTextFont], range: NSRange(countryAndDateString.startIndex..., in: countryAndDateString))
        
        if let countryNameAndEmojiRange = countryAndDateString.range(of: country.nameAndEmoji) {
            countryAndDateAttributedString.addAttributes([.foregroundColor: Settings.currentTheme.secondaryTitleColor, .font: Settings.currentFontSize.secondaryTitleFont], range: NSRange(countryNameAndEmojiRange, in: countryAndDateString))
        }
        
        return countryAndDateAttributedString
    }()
    
    /*
     Sample array:
     "May 11",
     "<a href="https://www.metal-archives.com/bands/Xeno_Ooze/3540452533">Xeno Ooze</a>",
     "<a href="https://www.metal-archives.com/lists/US">United States</a>",
     "Grindcore/Death/Sludge Metal",
     "May 11th, 09:10",
     "<a href="https://www.metal-archives.com/users/Euthanasiast" class="profileMenu">Euthanasiast</a>"
     */
    init?(from array: [String]) {
        guard array.count == 6 else { return nil }
        
        guard let urlSubstring = array[1].subString(after: #"href=""#, before: #"">"#, options: .caseInsensitive),
            let nameSubstring = array[1].subString(after: #"">"#, before: "</a>", options: .caseInsensitive) else {
                return nil
        }
        
        guard let countryIsoSubString = array[2].subString(after: "lists/", before: #"">"#, options: .caseInsensitive) else {
            return nil
        }
        
        guard let user = UserLite(from: array[5]) else {
            return nil
        }
        
        self.name = String(nameSubstring)
        self.country = Country(iso: String(countryIsoSubString))
        self.genre = array[3]
        self.updatedDateAndTimeString = array[4]
        self.user = user
        super.init(urlString: String(urlSubstring), imageType: .bandLogo)
    }
}
