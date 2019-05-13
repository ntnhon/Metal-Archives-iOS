//
//  ArtistAdditionOrUpdate.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 26/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

class ArtistAdditionOrUpdate: ThumbnailableObject {
    let nameInBand: String
    let realFullName: String?
    let country: Country?
    let bands: [BandLite]
    let updatedDate: Date
    let user: User
    
    /*
     Sample array:
     "May 13",
     "<a href="https://www.metal-archives.com/artists/Vergil_Alighieri/797018">Vergil Alighieri</a> (Valentin Rebrov)",
     "Russia</a>",
     "<a href="https://www.metal-archives.com/bands/Neuropolis/3540453710">Neuropolis</a>",
     "2019-05-13 14:44:19",
     "<a href="https://www.metal-archives.com/users/VladimirAlekseev" class="profileMenu">VladimirAlekseev</a>"
     */
    
    init?(from array: [String]) {
        guard array.count == 6 else { return nil }
        
        if let realFullNameSubstring = array[1].subString(after: "(", before: ")", options: .caseInsensitive) {
            self.realFullName = String(realFullNameSubstring)
        } else {
            self.realFullName = nil
        }
        
        guard let nameInBandSubstring = array[1].subString(after: #"">"#, before: "</a>", options: .caseInsensitive),
            let urlSubstring = array[1].subString(after: #"href=""#, before: #"">"#, options: .caseInsensitive) else { return nil }
        self.nameInBand = String(nameInBandSubstring)
        
        let countryName = array[2].replacingOccurrences(of: "</a>", with: "")
        self.country = Country(name: countryName)
        
        var bands: [BandLite] = []
        //Parse list of bands
        array[3].components(separatedBy: ",").forEach({ (eachATag) in
            
            if let bandNameSubString = eachATag.subString(after: #"">"#, before: "</a>", options: .caseInsensitive),
                let bandURLSubString = eachATag.subString(after: "href=\"", before: "\">", options: .caseInsensitive) {
                if let band = BandLite(name: String(bandNameSubString), urlString: String(bandURLSubString)) {
                    bands.append(band)
                }
            }
        })
        self.bands = bands
        
        guard let updatedDate = defaultDateFormatter.date(from: array[4]) else { return nil }
        self.updatedDate = updatedDate
        
        guard let user = User(from: array[5]) else { return nil }
        self.user = user
        
        super.init(urlString: String(urlSubstring), imageType: .artist)
    }
}

//MARK: - Actionable
extension ArtistAdditionOrUpdate: Actionable {
    var actionableElements: [ActionableElement] {
        var elements: [ActionableElement] = []
        
        let artistElement = ActionableElement(name: self.nameInBand, urlString: self.urlString, type: .artist)
        
        elements.append(artistElement)
        
        self.bands.forEach { (eachBand) in
            let bandElement = ActionableElement(name: eachBand.name, urlString: eachBand.urlString, type: .band)
            elements.append(bandElement)
        }
        
        return elements
    }
}
