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
    
    init?(urlString: String, nameInBand: String, realFullName: String?, country: Country?, bands: [BandLite], updatedDate: Date) {
        self.nameInBand = nameInBand
        self.realFullName = realFullName
        self.bands = bands
        self.country = country
        self.updatedDate = updatedDate
        super.init(urlString: urlString, imageType: .artist)
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
