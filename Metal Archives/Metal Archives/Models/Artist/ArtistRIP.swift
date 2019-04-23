//
//  ArtistRIP.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 19/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import AttributedLib

final class ArtistRIP: Thumbnailable {
    let name: String
    let country: Country?
    let bands: [BandLite]
    let dateOfDeath: String
    let causeOfDeath: String
    
    init?(urlString: String, name: String, country: Country?, bands: [BandLite], dateOfDeath: String, causeOfDeath: String) {
        self.name = name
        self.country = country
        self.bands = bands
        self.dateOfDeath = dateOfDeath
        self.causeOfDeath = causeOfDeath
        super.init(urlString: urlString, imageType: .artist)
    }
}

//MARK: - Pagable
extension ArtistRIP: Pagable {
    static var rawRequestURLString = "https://www.metal-archives.com/artist/ajax-rip?sEcho=2&iColumns=5&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=200&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&mDataProp_4=4&sSearch=<YEAR>&bRegex=false&sSearch_0=&bRegex_0=false&bSearchable_0=true&sSearch_1=&bRegex_1=false&bSearchable_1=true&sSearch_2=&bRegex_2=false&bSearchable_2=true&sSearch_3=&bRegex_3=false&bSearchable_3=true&sSearch_4=&bRegex_4=false&bSearchable_4=true&iSortCol_0=3&sSortDir_0=desc&iSortingCols=1&bSortable_0=true&bSortable_1=true&bSortable_2=false&bSortable_3=true&bSortable_4=false"
    static var displayLenght = 200
    
    static func parseListFrom(data: Data) -> (objects: [ArtistRIP]?, totalRecords: Int?)? {
        var list: [ArtistRIP] = []
        
        guard
            let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String:Any],
            let listArtistRIP = json["aaData"] as? [[String]]
            else {
                return nil
        }
        
        let totalRecords = json["iTotalRecords"] as? Int
        
        listArtistRIP.forEach { (eachArtistRIPDetails) in
            var name: String?
            if let nameSubString = eachArtistRIPDetails[0].subString(after: "\">", before: "</a>", options: .caseInsensitive) {
                name = String(nameSubString)
            }
            
            var urlString: String?
            if let urlSubString = eachArtistRIPDetails[0].subString(after: "href=\"", before: "\">", options: .caseInsensitive) {
                urlString = String(urlSubString)
            }
            
            let countryNameSubString = eachArtistRIPDetails[1]
            let country = Country(name: String(countryNameSubString))
            
            var bands: [BandLite] = []
            
            let eachBandDetails = eachArtistRIPDetails[2].components(separatedBy: ",")
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
            
            let dateOfDeath = eachArtistRIPDetails[3]
            let causeOfDeath = eachArtistRIPDetails[4]
            
            if let `name` = name, let `urlString` = urlString {
                if let artistRIP = ArtistRIP(urlString: urlString, name: name, country: country, bands: bands, dateOfDeath: dateOfDeath, causeOfDeath: causeOfDeath) {
                    list.append(artistRIP)
                }
            }
            
            
        }
        
        if list.count == 0 {
            return (nil, nil)
        }
        return (list, totalRecords)
    }
}

//MARK: - Actionable
extension ArtistRIP: Actionable {
    var actionableElements: [ActionableElement] {
        var elements: [ActionableElement] = []
        
        let artistElement = ActionableElement(name: self.name, urlString: self.urlString, type: .artist)
        elements.append(artistElement)
        
        self.bands.forEach { (eachBand) in
            let bandElement = ActionableElement(name: eachBand.name, urlString: eachBand.urlString, type: .band)
            elements.append(bandElement)
        }
        
        return elements
    }
}
