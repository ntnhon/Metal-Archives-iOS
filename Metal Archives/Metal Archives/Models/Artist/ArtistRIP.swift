//
//  ArtistRIP.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import AttributedLib

final class ArtistRIP: ThumbnailableObject, Pagable {
    let name: String
    let country: Country?
    let bands: [BandLite]
    let dateOfDeath: String
    let causeOfDeath: String
    
    static var rawRequestURLString = "https://www.metal-archives.com/artist/ajax-rip?sEcho=2&iColumns=5&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=200&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&mDataProp_4=4&sSearch=<YEAR>&bRegex=false&sSearch_0=&bRegex_0=false&bSearchable_0=true&sSearch_1=&bRegex_1=false&bSearchable_1=true&sSearch_2=&bRegex_2=false&bSearchable_2=true&sSearch_3=&bRegex_3=false&bSearchable_3=true&sSearch_4=&bRegex_4=false&bSearchable_4=true&iSortCol_0=3&sSortDir_0=desc&iSortingCols=1&bSortable_0=true&bSortable_1=true&bSortable_2=false&bSortable_3=true&bSortable_4=false"
    static var displayLength = 200
    
    init?(from array: [String]) {
        var name: String?
        if let nameSubString = array[0].subString(after: "\">", before: "</a>", options: .caseInsensitive) {
            name = String(nameSubString)
        }
        
        var urlString: String?
        if let urlSubString = array[0].subString(after: "href=\"", before: "\">", options: .caseInsensitive) {
            urlString = String(urlSubString)
        }
        
        let countryNameSubString = array[1]
        let country = Country(name: String(countryNameSubString))
        
        var bands: [BandLite] = []
        
        let eachBandDetails = array[2].components(separatedBy: ",")
        eachBandDetails.forEach({
            var bandName: String?
            if let bandNameSubString = $0.subString(after: "\">", before: "</a>", options: .caseInsensitive) {
                bandName = String(bandNameSubString)
            }
            
            var bandURLString: String?
            if let bandURLSubString = $0.subString(after: "href=\"", before: "\">", options: .caseInsensitive) {
                bandURLString = String(bandURLSubString)
            }
            
            if let `bandName` = bandName, let `bandURLString` = bandURLString {
                if let band = BandLite(name: bandName, urlString: bandURLString) {
                    bands.append(band)
                }
            }
        })
        
        let dateOfDeath = array[3]
        let causeOfDeath = array[4]
        
        if let name = name, let urlString = urlString {
            self.name = name
            self.country = country
            self.bands = bands
            self.dateOfDeath = dateOfDeath
            self.causeOfDeath = causeOfDeath
            super.init(urlString: urlString, imageType: .artist)
        } else {
            return nil
        }
    }
}

//MARK: - Actionable
extension ArtistRIP: Actionable {
    var actionableElements: [ActionableElement] {
        var elements: [ActionableElement] = []
        
        let artistElement = ActionableElement.artist(name: name, urlString: urlString)
        elements.append(artistElement)
        
        self.bands.forEach { (eachBand) in
            let bandElement = ActionableElement.band(name: eachBand.name, urlString: eachBand.urlString)
            elements.append(bandElement)
        }
        
        return elements
    }
}
