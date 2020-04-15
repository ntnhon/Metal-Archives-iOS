//
//  UserCollection.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 15/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import AttributedLib

class UserCollection {
    let bands: [BandLite]
    let release: ReleaseExtraLite
    let type: String
    let version: String
    let notes: String?
    let forTrade: Bool
    
    lazy var bandsAttributedString: NSAttributedString = {
        let bandNames = bands.map({$0.name})
        return generateAttributedStringFromStrings(bandNames, as: .secondaryTitle, withSeparator: " / ")
    }()
    
    lazy var titleAndTypeAttributedString: NSAttributedString = {
        return release.title.at.attributed(with: titleAttributes) + " \(type)".at.attributed(with: bigBodyTextAttributes)
    }()
    
    /*
     Sample array:
     "<a class="iconContainer ui-state-default ui-corner-all" href="https://www.metal-archives.com/collection/owner-list/releaseId/60746" title="See who owns / wants this album"><span class="ui-icon ui-icon-person">Owners</span></a>",
     "<a href="https://www.metal-archives.com/bands/Akitsa/2224">Akitsa</a> / <a href="https://www.metal-archives.com/bands/The_Shadow_Order/7539">The Shadow Order</a>",
     "<a href="https://www.metal-archives.com/albums/Akitsa_-_The_Shadow_Order/Guerre_-_%CE%A0%CE%BF%CE%BB%CE%B5%CE%BC%CE%BF%CF%82/60746">Guerre / Πολεμος</a> (Split)",
     "<span id='version_60746_0'>Unspecified </span>",
     "mp3",
     "<span class='iconContainer'><span class='ui-icon ui-icon-check' title='Yes'>Yes</span></span>"
     */
    
    init?(from array: [String]) {
        guard array.count == 5 || array.count == 6 else { return nil }
        
        guard let bands = Array<BandLite>.fromString(array[1]) else { return nil}
        
        guard let release = ReleaseExtraLite(from: array[2]), let typeSubstring = array[2].subString(after: "</a>") else {
                return nil
        }
        
        guard let versionSubstring = array[3].subString(after: "'>", before: " </span>", options: .caseInsensitive) else { return nil }
        
        self.bands = bands
        self.release = release
        self.type = String(typeSubstring)
        self.version = String(versionSubstring)
        
        let notes = array[4]
        if notes != "" {
            self.notes = notes
        } else {
            self.notes = nil
        }
        
        if array.count == 6 {
            self.forTrade = array[5].contains("Yes")
        } else {
            self.forTrade = false
        }
    }
}

extension UserCollection: Actionable {
    var actionableElements: [ActionableElement] {
        var elements: [ActionableElement] = []
        
        let releaseElement = ActionableElement.release(name: release.title, urlString: release.urlString)
        elements.append(releaseElement)
        
        self.bands.forEach { (eachBand) in
            let bandElement = ActionableElement.band(name: eachBand.name, urlString: eachBand.urlString)
            elements.append(bandElement)
        }
        
        return elements
    }
}

final class UserAlbumCollection: UserCollection, Pagable {
    static var rawRequestURLString =   "https://www.metal-archives.com/collection/ajax-view/id/<USER_ID>/type/1/json/1?sEcho=1&iColumns=6&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=<DISPLAY_LENGTH>&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&mDataProp_4=4&mDataProp_5=5&_=1586945145862"
    
    static var displayLenght = 200
    
    static func parseListFrom(data: Data) -> (objects: [UserAlbumCollection]?, totalRecords: Int?)? {
        guard let (totalRecords, array) = parseTotalRecordsAndArrayOfRawValues(data) else {
            return nil
        }
        var list: [UserAlbumCollection] = []
        
        array.forEach { (userAlbumCollectionDetails) in
            if let userAlbumCollection = UserAlbumCollection(from: userAlbumCollectionDetails) {
                list.append(userAlbumCollection)
            }
        }
        
        if list.count == 0 {
            return (nil, nil)
        }
        return (list, totalRecords)
    }
}

final class UserWantedRelease: UserCollection, Pagable {
    static var rawRequestURLString = "https://www.metal-archives.com/collection/ajax-view/id/<USER_ID>/type/3/json/1?sEcho=1&iColumns=5&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=<DISPLAY_LENGTH>&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&mDataProp_4=4&_=1586959069460"
    
    static var displayLenght = 200
    
    static func parseListFrom(data: Data) -> (objects: [UserWantedRelease]?, totalRecords: Int?)? {
        guard let (totalRecords, array) = parseTotalRecordsAndArrayOfRawValues(data) else {
            return nil
        }
        var list: [UserWantedRelease] = []
        
        array.forEach { (userWantedReleaseDetails) in
            if let userWantedRelease = UserWantedRelease(from: userWantedReleaseDetails) {
                list.append(userWantedRelease)
            }
        }
        
        if list.count == 0 {
            return (nil, nil)
        }
        return (list, totalRecords)
    }
}

final class UserReleaseForTrade: UserCollection, Pagable {
    static var rawRequestURLString =   "https://www.metal-archives.com/collection/ajax-view/id/<USER_ID>/type/2/json/1?sEcho=1&iColumns=5&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=<DISPLAY_LENGTH>&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&mDataProp_4=4&_=1586958990689"
    
    static var displayLenght = 200
    
    static func parseListFrom(data: Data) -> (objects: [UserReleaseForTrade]?, totalRecords: Int?)? {
        guard let (totalRecords, array) = parseTotalRecordsAndArrayOfRawValues(data) else {
            return nil
        }
        var list: [UserReleaseForTrade] = []
        
        array.forEach { (userReleaseForTradeDetails) in
            if let userReleaseForTrade = UserReleaseForTrade(from: userReleaseForTradeDetails) {
                list.append(userReleaseForTrade)
            }
        }
        
        if list.count == 0 {
            return (nil, nil)
        }
        return (list, totalRecords)
    }
}
