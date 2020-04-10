//
//  Country.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 28/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class Country: Equatable {
    let iso: String
    let emoji: String
    let name: String
    
    var nameAndEmoji: String {
        return "\(name) \(emoji)"
    }
    
    static let unknownCountry = Country(iso: "ZZ", emoji: "🏳️", name: "Unknown")
    
    fileprivate init(iso: String, emoji: String, name: String) {
        self.iso = iso
        self.emoji = emoji
        self.name = name
    }
    
    init(iso: String) {
        if iso.count != 2 {
            self.iso = "ZZ"
            self.emoji = "🏳️"
            self.name = "Unknown"
            return
        }
        
        for (eachISO, eachISODictionary) in countryDictionary {
            guard let `eachISO` = eachISO as? String, let `eachISODictionary` = eachISODictionary as? NSDictionary else {
                self.iso = "ZZ"
                self.emoji = "🏳️"
                self.name = "Unknown"
                return
            }
            
            if eachISO.caseInsensitiveCompare(iso) == .orderedSame {
                self.iso = eachISO
                self.emoji = eachISODictionary["Emoji"] as! String
                self.name = eachISODictionary["Name"] as! String
                return
            }
        }
        
        self.iso = "ZZ"
        self.emoji = "🏳️"
        self.name = "Unknown"
        return
    }
    
    init(name: String) {
        for (eachISO, eachISODictionary) in countryDictionary {
            guard let `eachISO` = eachISO as? String, let `eachISODictionary` = eachISODictionary as? NSDictionary else {
                self.iso = "ZZ"
                self.emoji = "🏳️"
                self.name = "Unknown"
                return
            }
            
            guard let countryName = eachISODictionary["Name"] as? String else {
                self.iso = "ZZ"
                self.emoji = "🏳️"
                self.name = "Unknown"
                return
            }
            
            if name == countryName {
                self.iso = eachISO
                self.emoji = eachISODictionary["Emoji"] as! String
                self.name = countryName
                return
            }
        }
        
        self.iso = "ZZ"
        self.emoji = "🏳️"
        self.name = "Unknown"
        return
    }
    
    init(emoji: String) {
        for (eachISO, eachISODictionary) in countryDictionary {
            guard let `eachISO` = eachISO as? String, let `eachISODictionary` = eachISODictionary as? NSDictionary else {
                self.iso = "ZZ"
                self.emoji = "🏳️"
                self.name = "Unknown"
                return
            }
            
            guard let countryEmoji = eachISODictionary["Emoji"] as? String else {
                self.iso = "ZZ"
                self.emoji = "🏳️"
                self.name = "Unknown"
                return
            }
            
            if emoji == countryEmoji {
                self.iso = eachISO
                self.emoji = countryEmoji
                self.name = eachISODictionary["Name"] as! String
                return
            }
        }
        
        self.iso = "ZZ"
        self.emoji = "🏳️"
        self.name = "Unknown"
        return
    }
    
    static func == (lhs: Country, rhs: Country) -> Bool {
        return lhs.iso == rhs.iso
    }
}
