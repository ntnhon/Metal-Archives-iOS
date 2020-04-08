//
//  UpcomingAlbum.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 15/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import EventKit

final class UpcomingAlbum: NSObject {
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
            typeAndDateAttributedString.addAttributes([.foregroundColor: Settings.currentTheme.bodyTextColor, .font: Settings.currentFontSize.boldBodyTextFont], range: NSRange(typeRange, in: typeAndDateString))
        }
        
        return typeAndDateAttributedString
    }()
    
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
    
    func createEvent() -> EKEvent {
        let event = EKEvent(eventStore: EKEventStore())
        event.title = "\(release.title) | \(bands.map({$0.name}).joined(separator: "/")) | \(releaseType.description) | \(genre)"
        event.notes = """
        \(bands.map({$0.name}).joined(separator: "/"))
        \(releaseType.description)
        \(genre)
        """
        
        event.url = URL(string: release.urlString)
        
        let dateElements = date.split(separator: " ", maxSplits: 3, omittingEmptySubsequences: true)
        
        // Ex: September 12th, 2020
        guard dateElements.count == 3 else { return event }
        
        let monthString = dateElements[0]
        var dayString = dateElements[1]
        dayString.removeLast(3)
        
        let yearString = dateElements[2]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d/MMMM/yyyy"
        let dateString = "\(dayString)/\(monthString)/\(yearString)"
        let eventDate = dateFormatter.date(from: dateString)
        
        event.startDate = eventDate?.addingTimeInterval(10*60*60)
        event.endDate = eventDate?.addingTimeInterval(12*60*60)
        
        return event
    }
}

//MARK: - Pagable
extension UpcomingAlbum: Pagable {
    static var rawRequestURLString = "https://www.metal-archives.com/release/ajax-upcoming/json/1?sEcho=1&iColumns=5&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=100&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&mDataProp_4=4&iSortCol_0=4&sSortDir_0=asc&iSortingCols=1&bSortable_0=true&bSortable_1=true&bSortable_2=true&bSortable_3=true&bSortable_4=true"
    static var displayLenght = 100
    
    static func parseListFrom(data: Data) -> (objects: [UpcomingAlbum]?, totalRecords: Int?)? {
        guard let (totalRecords, array) = parseTotalRecordsAndArrayOfRawValues(data) else {
            return nil
        }
        var list: [UpcomingAlbum] = []
        
        array.forEach { (upcomingAlbumDetails) in
            if let upcomingAlbum = UpcomingAlbum(from: upcomingAlbumDetails) {
                list.append(upcomingAlbum)
            }
        }
        
        if list.count == 0 {
            return (nil, nil)
        }
        return (list, totalRecords)
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
        
        let eventElement = ActionableElement.event(event: createEvent())
        elements.append(eventElement)
        
        return elements
    }
}
