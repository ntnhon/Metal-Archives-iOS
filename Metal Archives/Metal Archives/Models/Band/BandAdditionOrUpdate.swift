//
//  BandAdditionOrUpdate.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 12/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

class BandAdditionOrUpdate: Thumbnailable {
    let updatedDateString: String
    let name: String
    let country: Country
    let genre: String
    let updatedDateAndTimeString: String
    
    init?(updatedDateString: String, name: String, urlString: String, countryURLString: String, genre: String, updatedDateAndTimeString: String) {
        if let countryISO = countryURLString.components(separatedBy: "/").last, let country = Country(iso: countryISO) {
            self.country = country
        } else {
            return nil
        }
        
        self.updatedDateString = updatedDateString
        self.name = name
        self.genre = genre
        self.updatedDateAndTimeString = updatedDateAndTimeString
        super.init(urlString: urlString, imageType: .bandLogo)
    }
}

