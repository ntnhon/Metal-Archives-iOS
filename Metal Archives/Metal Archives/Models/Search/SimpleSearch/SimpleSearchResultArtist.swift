//
//  SimpleSearchResultArtist.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 05/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class SimpleSearchResultArtist: Pagable {
    let artist: ArtistExtraLite
    let aka: String?
    let realName: String
    let country: Country?
    let bands: [BandNullable]
    
    static var rawRequestURLString = "https://www.metal-archives.com/search/ajax-artist-search/?field=alias&query=<QUERY>&sEcho=2&iColumns=4&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=200&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3"
    
    static var displayLength = 200
    
    init?(from array: [String]) {
        var artist: ArtistExtraLite?
        var aka: String?
        
        if array.indices.contains(0) {
            var artistName: String?
            var urlString: String?
            
            if let subString = array[0].subString(after: "\">", before: "</a>", options: .caseInsensitive) {
                artistName = String(subString)
            }
            
            if let subString = array[0].subString(after: "href=\"", before: "\">", options: .caseInsensitive) {
                urlString = String(subString)
            }
            
            if array[0].contains("a.k.a") {
                if let subString = array[0].subString(after: "</a> (", before: ")", options: .caseInsensitive) {
                    aka = subString.replacingOccurrences(of: "<strong>", with: "").replacingOccurrences(of: "</strong>", with: "").replacingOccurrences(of: "&quot;", with: "").replacingOccurrences(of: "<em>", with: "").replacingOccurrences(of: "</em>", with: "")
                    
                }
            }
            
            if let `artistName` = artistName, let `urlString` = urlString {
                artist = ArtistExtraLite(urlString: urlString, name: artistName)
            }
        }
        
        let realName: String? = array.indices.contains(1) ? array[1] : nil
        
        let countryName: String? = array.indices.contains(2) ? array[2] : nil
        var country: Country?
        if let `countryName` = countryName {
            country = Country(name: countryName)
        }
        
        var bands: [BandNullable]?
        
        if array.indices.contains(3) {
            bands = []
            let detailComponents = array[3].components(separatedBy: ", ")
            
            detailComponents.forEach({ (eachComponent) in
                var bandName: String?
                var urlString: String?
                if let subString = eachComponent.subString(after: "\">", before: "</a>", options: .caseInsensitive) {
                    bandName = String(subString)
                }
                
                if let subString = eachComponent.subString(after: "href=\"", before: "\"", options: .caseInsensitive) {
                    urlString = String(subString)
                }
                
                if let `bandName` = bandName {
                    let band = BandNullable(name: bandName, urlString: urlString)
                    bands?.append(band)
                } else {
                    //In case band is not existed on the site
                    bandName = eachComponent.replacingOccurrences(of: "&nbsp;", with: "")
                    if let `bandName` = bandName {
                        let band = BandNullable(name: bandName, urlString: urlString)
                        bands?.append(band)
                    }
                }
            })
        }
        
        if let artist = artist, let realName = realName, let bands = bands {
            self.artist = artist
            self.aka = aka
            self.realName = realName
            self.country = country
            self.bands = bands
        } else {
            return nil
        }
    }
}

//MARK: - Actionable
extension SimpleSearchResultArtist: Actionable {
    var actionableElements: [ActionableElement] {
        var elements: [ActionableElement] = []
        
        let artistElement = ActionableElement.artist(name: artist.name, urlString: artist.urlString)
        elements.append(artistElement)
        
        self.bands.forEach { (nullableBand) in
            if let bandURLString = nullableBand.urlString {
                let bandElement = ActionableElement.band(name: nullableBand.name, urlString: bandURLString)
                elements.append(bandElement)
            }
        }
        
        return elements
    }
}
