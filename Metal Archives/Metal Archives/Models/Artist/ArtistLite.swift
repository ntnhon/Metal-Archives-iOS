//
//  ArtistLite.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 30/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class ArtistLite: ThumbnailableObject {
    let name: String
    let instrumentsInBand: String
    let bands: [BandLite]?
    let seeAlsoString: String?
    
    lazy var seeAlsoAttributedString: NSAttributedString? = {
        guard let seeAlsoString = self.seeAlsoString else { return nil }
        
        let mutableAttributedString = NSMutableAttributedString(string: seeAlsoString)
        mutableAttributedString.addAttributes([.foregroundColor: Settings.currentTheme.bodyTextColor, .font: Settings.currentFontSize.bodyTextFont], range: NSRange(seeAlsoString.startIndex..., in: seeAlsoString))
        
        guard let bands = self.bands else {
            return mutableAttributedString
        }
        
        for band in bands {
            if let bandNameRange = seeAlsoString.range(of: band.name) {
                mutableAttributedString.addAttributes([.foregroundColor: Settings.currentTheme.secondaryTitleColor], range: NSRange(bandNameRange, in: seeAlsoString))
            }
        }
        
        return mutableAttributedString
    }()
    
    init?(urlString: String, name: String, instrumentsInBand: String, bands: [BandLite]?, seeAlsoString: String?) {
        self.name = name
        self.instrumentsInBand = instrumentsInBand
        if let bands = bands, bands.count == 0 {
            self.bands = nil
        } else {
            self.bands = bands
        }
        self.seeAlsoString = seeAlsoString
        super.init(urlString: urlString, imageType: .artist)
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
