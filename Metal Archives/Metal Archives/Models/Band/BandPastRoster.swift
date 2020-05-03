//
//  BandPastRoster.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 24/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class BandPastRoster: ThumbnailableObject, Pagable {
    let name: String
    let genre: String
    let country: Country
    let numberOfReleases: Int
    
    lazy var countryAndNumOfReleasesAttributedString: NSAttributedString = {
        var countryAndNumOfReleasesString = ""
        if numberOfReleases <= 1 {
            countryAndNumOfReleasesString = "\(country.nameAndEmoji) • \(numberOfReleases) release"
        } else {
            countryAndNumOfReleasesString = "\(country.nameAndEmoji) • \(numberOfReleases) releases"
        }
        
        let countryAndNumOfReleasesMutableAttributedString = NSMutableAttributedString(string: countryAndNumOfReleasesString)
        countryAndNumOfReleasesMutableAttributedString.addAttributes([.foregroundColor: Settings.currentTheme.bodyTextColor, .font: Settings.currentFontSize.bodyTextFont], range: NSRange(countryAndNumOfReleasesString.startIndex..., in: countryAndNumOfReleasesString))
        
        if let countryRange = countryAndNumOfReleasesString.range(of: country.nameAndEmoji) {
            countryAndNumOfReleasesMutableAttributedString.addAttributes([.foregroundColor: Settings.currentTheme.secondaryTitleColor], range: NSRange(countryRange, in: countryAndNumOfReleasesString))
        }
        
        return countryAndNumOfReleasesMutableAttributedString
    }()
    
    static var rawRequestURLString = "https://www.metal-archives.com/label/ajax-bands-past/nbrPerPage/100/id/<LABEL_ID>?sEcho=1&iColumns=4&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=100&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&iSortCol_0=0&sSortDir_0=asc&iSortingCols=1&bSortable_0=true&bSortable_1=true&bSortable_2=true&bSortable_3=true"
    
    static var displayLength = 100
    
    init?(from array: [String]) {
        //Workaround in case ' instead of "
        //from: <a href='https://www.metal-archives.com/bands/Red_Ruin/3540450310'>Red Ruin</a>
        //to: <a href=\"https://www.metal-archives.com/bands/Red_Ruin/3540450310\">Red Ruin</a>
        var a = array[0]
        a = a.replacingOccurrences(of: "href='", with: "href=\"")
        a = a.replacingOccurrences(of: "href=\'", with: "href=\"")
        a = a.replacingOccurrences(of: "'>", with: "\">")
        
        let bandName = String(a.subString(after: "\">", before: "</a>", options: .caseInsensitive) ?? "")
        let bandURLString = String(a.subString(after: "href=\"", before: "\">", options: .caseInsensitive) ?? "")
        
        let genre = array[1]
        let countryName = array[2]

        if let numberOfReleases = Int(array[3]) {
            self.name = bandName
            self.genre = genre
            self.country = Country(name: countryName)
            self.numberOfReleases = numberOfReleases
            super.init(urlString: bandURLString, imageType: .bandLogo)
        } else {
            return nil
        }
    }
}
