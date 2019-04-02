//
//  SimpleSearchResultArtist.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 05/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class SimpleSearchResultArtist {
    let artist: ArtistExtraLite
    let aka: String?
    let realName: String
    let country: Country?
    let bands: [BandNullable]
    
    init(artist: ArtistExtraLite, aka: String?, realName: String, country: Country?, bands: [BandNullable]) {
        self.artist = artist
        self.aka = aka
        self.realName = realName
        self.country = country
        self.bands = bands
    }
}

//MARK: - Pagable
extension SimpleSearchResultArtist: Pagable {
    static var rawRequestURLString = "https://www.metal-archives.com/search/ajax-artist-search/?field=alias&query=<QUERY>&sEcho=2&iColumns=4&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=200&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3"
    static var displayLenght = 200
    
    static func parseListFrom(data: Data) -> (objects: [SimpleSearchResultArtist]?, totalRecords: Int?)? {
        var list: [SimpleSearchResultArtist] = []
        
        guard
            let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String:Any],
            let listSimpleSearchResultArtist = json?["aaData"] as? [[String]]
            else {
                return nil
        }
        
        let totalRecords = json?["iTotalRecords"] as? Int
        
        listSimpleSearchResultArtist.forEach { (eachDetail) in
            var artist: ArtistExtraLite?
            var aka: String?
            
            if eachDetail.indices.contains(0) {
                var artistName: String?
                var urlString: String?
                
                if let subString = eachDetail[0].subString(after: "\">", before: "</a>", options: .caseInsensitive) {
                    artistName = String(subString)
                }
                
                if let subString = eachDetail[0].subString(after: "href=\"", before: "\">", options: .caseInsensitive) {
                    urlString = String(subString)
                }
                
                if eachDetail[0].contains("a.k.a") {
                    if let subString = eachDetail[0].subString(after: "</a> (", before: ")", options: .caseInsensitive) {
                        aka = subString.replacingOccurrences(of: "<strong>", with: "").replacingOccurrences(of: "</strong>", with: "").replacingOccurrences(of: "&quot;", with: "").replacingOccurrences(of: "<em>", with: "").replacingOccurrences(of: "</em>", with: "")
                        
                    }
                }
                
                if let `artistName` = artistName, let `urlString` = urlString {
                    artist = ArtistExtraLite(urlString: urlString, name: artistName)
                }
            }
            
            let realName: String? = eachDetail.indices.contains(1) ? eachDetail[1] : nil
            
            let countryName: String? = eachDetail.indices.contains(2) ? eachDetail[2] : nil
            var country: Country?
            if let `countryName` = countryName {
                country = Country(name: countryName)
            }
            
            var bands: [BandNullable]?
            
            if eachDetail.indices.contains(3) {
                bands = []
                let detailComponents = eachDetail[3].components(separatedBy: ", ")
                
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
            
            if let `artist` = artist, let `realName` = realName, let `bands` = bands {
                let result = SimpleSearchResultArtist(artist: artist, aka: aka, realName: realName, country: country, bands: bands)
                list.append(result)
            }
        }
        
        if list.count == 0 {
            return (nil, nil)
        }
        return (list, totalRecords)
    }
}

//MARK: - Actionable
extension SimpleSearchResultArtist: Actionable {
    var actionableElements: [ActionableElement] {
        var elements: [ActionableElement] = []
        
        let artistElement = ActionableElement(name: self.artist.name, urlString: self.artist.urlString, type: .artist)
        elements.append(artistElement)
        
        self.bands.forEach { (nullableBand) in
            if let bandURLString = nullableBand.urlString {
                let bandElement = ActionableElement(name: nullableBand.name, urlString: bandURLString, type: .band)
                elements.append(bandElement)
            }
        }
        
        return elements
    }
}
