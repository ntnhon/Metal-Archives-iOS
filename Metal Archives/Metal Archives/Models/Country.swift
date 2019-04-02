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
    
    init?(iso: String) {
        if iso.count != 2 {
            return nil
        }
        
        for (eachISO, eachISODictionary) in countryDictionary {
            guard let `eachISO` = eachISO as? String, let `eachISODictionary` = eachISODictionary as? NSDictionary else {
                return nil
            }
            
            if eachISO.caseInsensitiveCompare(iso) == .orderedSame {
                self.iso = eachISO
                self.emoji = eachISODictionary["Emoji"] as! String
                self.name = eachISODictionary["Name"] as! String
                return
            }
        }
        
        return nil
    }
    
    init?(name: String) {
        for (eachISO, eachISODictionary) in countryDictionary {
            guard let `eachISO` = eachISO as? String, let `eachISODictionary` = eachISODictionary as? NSDictionary else {
                return nil
            }
            
            guard let countryName = eachISODictionary["Name"] as? String else {
                return nil
            }
            
            if name == countryName {
                self.iso = eachISO
                self.emoji = eachISODictionary["Emoji"] as! String
                self.name = countryName
                return
            }
        }
        
        return nil
    }
    
    init?(emoji: String) {
        for (eachISO, eachISODictionary) in countryDictionary {
            guard let `eachISO` = eachISO as? String, let `eachISODictionary` = eachISODictionary as? NSDictionary else {
                return nil
            }
            
            guard let countryEmoji = eachISODictionary["Emoji"] as? String else {
                return nil
            }
            
            if emoji == countryEmoji {
                self.iso = eachISO
                self.emoji = countryEmoji
                self.name = eachISODictionary["Name"] as! String
                return
            }
        }
        
        return nil
    }
    
    static func == (lhs: Country, rhs: Country) -> Bool {
        return lhs.iso == rhs.iso
    }
}
