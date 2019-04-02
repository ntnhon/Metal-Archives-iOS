//
//  ArtistLite.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 30/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class ArtistLite: Thumbnailable {
    let name: String
    let instrumentsInBand: String
    private(set) var bands: [BandLite]?
    private(set) var seeAlsoString: String?
    
    init?(urlString: String, name: String, instrumentsInBand: String) {
        self.name = name
        self.instrumentsInBand = instrumentsInBand
        super.init(urlString: urlString, imageType: .artist)
    }
    
    init?() {
        return nil
    }
    
    func setBands(_ bands: [BandLite]?) {
        self.bands = bands
    }
    
    func setSeeAlsoString(_ seeAlsoString: String?) {
        self.seeAlsoString = seeAlsoString
    }
}

//MARK: - Actionable
extension ArtistLite: Actionable {
    var actionableElements: [ActionableElement] {
        var elements: [ActionableElement] = []
        
        let artistElement = ActionableElement(name: self.name, urlString: self.urlString, type: .artist)
        elements.append(artistElement)
        
        self.bands?.forEach({ (eachBand) in
            let bandElement = ActionableElement(name: eachBand.name, urlString: eachBand.urlString, type: .band)
            elements.append(bandElement)
        })
        
        return elements
    }
}
