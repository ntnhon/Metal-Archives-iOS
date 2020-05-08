//
//  UpcomingAlbum.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 15/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import EventKit
import UIKit

final class UpcomingAlbum: NSObject, Pagable {
    let bands: [BandLite]
    let release: ReleaseExtraLite
    let releaseType: ReleaseType
    @objc let genre: String
    let date: String
    
    lazy var combinedBandNamesAttributedString: NSAttributedString = {
        let bandNames = bands.map { (band) -> String in
            return band.name
        }
        return generateAttributedStringFromStrings(bandNames, as: .title, withSeparator: " / ")
    }()
    
    lazy var typeAndDateAttributedString: NSAttributedString = {
        let typeAndDateString = "\(releaseType.description) • \(date)"
        let typeAndDateAttributedString = NSMutableAttributedString(string: typeAndDateString)
        
        typeAndDateAttributedString.addAttributes([.foregroundColor: Settings.currentTheme.bodyTextColor, .font: Settings.currentFontSize.bodyTextFont], range: NSRange(typeAndDateString.startIndex..., in: typeAndDateString))
        
        if let typeRange = typeAndDateString.range(of: releaseType.description) {
            let font: UIFont
            switch releaseType {
            case .fullLength: font = Settings.currentFontSize.heavyBodyTextFont
            case .demo: font = Settings.currentFontSize.italicBodyTextFont
            case .single: font = Settings.currentFontSize.tertiaryFont
            default: font = Settings.currentFontSize.bodyTextFont
            }
            
            typeAndDateAttributedString.addAttributes([.foregroundColor: Settings.currentTheme.bodyTextColor, .font: font], range: NSRange(typeRange, in: typeAndDateString))
        }
        
        return typeAndDateAttributedString
    }()
    
    lazy var event: EKEvent? = {
        let title = "\(release.title) | \(bands.map({$0.name}).joined(separator: "/")) | \(releaseType.description) | \(genre)"
        let notes = """
        Release title: \(release.title)
        Band(s): \(bands.map({$0.name}).joined(separator: "/"))
        Type: \(releaseType.description)
        Genre: \(genre)
        """
        
        let url = URL(string: release.urlString)
        
        return EKEvent.createEventFrom(dateString: date, title: title, notes: notes, url: url)
    }()
    
    static var rawRequestURLString = "https://www.metal-archives.com/release/ajax-upcoming/json/1?sEcho=1&iColumns=5&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=100&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&mDataProp_4=4&iSortCol_0=4&sSortDir_0=asc&iSortingCols=1&bSortable_0=true&bSortable_1=true&bSortable_2=true&bSortable_3=true&bSortable_4=true"
    
    static var displayLength = 100
    
    /*
     Sample array:
     "<a href="https://www.metal-archives.com/bands/Kalmankantaja/3540342889">Kalmankantaja</a> / <a href="https://www.metal-archives.com/bands/Drudensang/3540369476">Drudensang</a> / <a href="https://www.metal-archives.com/bands/Hiisi/3540401566">Hiisi</a>",
     "<a href="https://www.metal-archives.com/albums/Kalmankantaja_-_Drudensang_-_Hiisi/Essence_of_Black_Mysticism/775924">Essence of Black Mysticism</a>",
     "Split",
     "Depressive Black Metal (early), Atmospheric Black Metal (later) | Black Metal | Black Metal",
     "May 13th, 2019"
     */
    
    init?(from array: [String]) {
        guard array.count == 5 else { return nil }
        
        guard let release = ReleaseExtraLite(from: array[1]) else { return nil }
        
        guard let releaseType = ReleaseType(typeString: array[2]) else { return nil }
        
        // Workaround: In case of split release where there are many bands
        // replace " / " by a special character in order to split by this character (cause split string function only splits by character, not a string)
        var bands = [BandLite]()
        array[0].replacingOccurrences(of: " / ", with: "😡").split(separator: "😡").forEach({
            if let band = BandLite(from: String($0)) {
                bands.append(band)
            }
        })
        
        guard bands.count > 0 else { return nil }
        
        self.bands = bands
        self.release = release
        self.releaseType = releaseType
        self.genre = array[3]
        self.date = array[4]
    }
}

//MARK: - Actionable
extension UpcomingAlbum: Actionable {
    var actionableElements: [ActionableElement] {
        var elements: [ActionableElement] = []
        
        self.bands.forEach { (eachBand) in
            let bandElement = ActionableElement.band(name: eachBand.name, urlString: eachBand.urlString)
            elements.append(bandElement)
        }
        
        let releaseElement = ActionableElement.release(name: release.title, urlString: release.urlString)
        elements.append(releaseElement)
        
        if let event = event {
            let eventElement = ActionableElement.event(event: event)
            elements.append(eventElement)
        }
    
        return elements
    }
}
