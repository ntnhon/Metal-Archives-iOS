//
//  Release.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 05/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import Kanna
import EventKit

final class Release {
    private(set) var id: String!
    private(set) var urlString: String!
    private(set) var bands: [BandLite]!
    private(set) var coverURLString: String?
    private(set) var reviewsURLString: String?
    private(set) var title: String!
    private(set) var type: ReleaseType!
    private(set) var dateString: String!
    private(set) var catalogID: String!
    private(set) var label: LabelLiteInBand!
    private(set) var format: String!
    private(set) var additionalHTMLNotes: String?
    private(set) var reviewCount: Int?
    private(set) var rating: Int?
    private(set) var auditTrail: AuditTrail!
    
    private(set) var isBookmarked: Bool? = nil
    
    private(set) var elements: [ReleaseElement]!
    private(set) var completeLineup: [ArtistLiteInRelease]!
    private(set) var bandMembers: [ArtistLiteInRelease]!
    private(set) var guestSession: [ArtistLiteInRelease]!
    private(set) var otherStaff: [ArtistLiteInRelease]!
    private(set) var reviews: [ReviewLiteInRelease]!
    private(set) var otherVersions: [ReleaseOtherVersion]!
    
    lazy var completeLineupDescription: String = {
        if let complete = self.completeLineup {
            if complete.count <= 1 {
                return "Complete lineup (\(complete.count) artist)"
            } else {
                return "Complete lineup (\(complete.count) artists)"
            }
        }
        
        return "Complete lineup (0 artist)"
    }()
    lazy var bandMembersDescription: String = {
        if let bandMembers = self.bandMembers {
            if bandMembers.count <= 1 {
                return "Band members (\(bandMembers.count) artist)"
            } else {
                return "Band members (\(bandMembers.count) artists)"
            }
        }
        
        return "Band members (0 artist)"
    }()
    lazy var guestSessionDescription: String = {
        if let guestSession = self.guestSession {
            if guestSession.count <= 1 {
                return "Guest/session musicians (\(guestSession.count) artist)"
            } else {
                return "Guest/session musicians (\(guestSession.count) artists)"
            }
        }
        
        return "Guest/session musicians (0 artist)"
    }()
    lazy var otherStaffDescription: String = {
        if let otherStaff = self.otherStaff {
            if otherStaff.count <= 1 {
                return "Other staff (\(otherStaff.count) artist)"
            } else {
                return "Other staff (\(otherStaff.count) artists)"
            }
        }
        
        return "Other staff (0 artist)"
    }()
    
    lazy var event: EKEvent? = {
        let eventTitle = "\(title ?? "") | \(bands.map({$0.name}).joined(separator: "/")) | \(type.description)"
        let notes = """
        Release title: \(title ?? "")
        Band(s): \(bands.map({$0.name}).joined(separator: "/"))
        Type: \(type.description)
        """
        
        let url = URL(string: urlString)
        
        return EKEvent.createEventFrom(dateString: dateString, title: eventTitle, notes: notes, url: url)
    }()
    
    lazy var reviewStatsAttributedString: NSAttributedString? = {
        guard let reviewCount = reviewCount, let rating = rating else { return nil }
        
        var string = "\(reviewCount) \(reviewCount > 1 ? "reviews" : "review") • \(rating)%"
        if reviewCount >= 10 && rating >= 75 {
            string += " 🏅"
        }
        
        let attributedString = NSMutableAttributedString(string: string)
        attributedString.addAttributes([
            .foregroundColor: Settings.currentTheme.bodyTextColor,
            .font: Settings.currentFontSize.bodyTextFont],range: NSRange(string.startIndex..., in: string))
        
        // Bold reviewCount
        if let range = string.range(of: "\(reviewCount)") {
            attributedString.addAttribute(.font, value: Settings.currentFontSize.boldBodyTextFont, range: NSRange(range, in: string))
        }
        
        // Color rating
        if let range = string.range(of: "\(rating)%") {
            attributedString.addAttribute(.foregroundColor, value: UIColor.colorByRating(rating), range: NSRange(range, in: string))
        }
        
        return attributedString
    }()
    
    func setOtherVersions(_ otherVersions: [ReleaseOtherVersion]) {
        self.otherVersions = otherVersions
    }
    
    deinit {
        print("Release is deallocated")
    }
    
    func setIsBookmarked(_ isBookmarked: Bool) {
        self.isBookmarked = isBookmarked
    }
    
    init?(data: Data) {
        guard let htmlString = String(data: data, encoding: String.Encoding.utf8),
            let doc = try? Kanna.HTML(html: htmlString, encoding: String.Encoding.utf8) else {
                return nil
        }
        
        // Firstly detect if release is bookmarked or not
        for a in doc.css("a") {
            // When bookmarked
            // <a id="bookmark" class="iconContainer ui-state-active ui-corner-all writeAction"...
            // When not bookmarked
            // <a id="bookmark" class="iconContainer ui-state-default ui-corner-all writeAction"...
            if let id = a["id"], id == "bookmark", let classValue = a["class"] {
                self.isBookmarked = classValue.contains("active")
                continue
            }
        }
        
        // Workaround
        /* Khi hiện other version có trường hợp meta data có thêm trường mới (Version desc, Authenticity)
         => đếm số trường (> 6 trường) và skip
         */
        var countTemp = 0
        var skipped = false
        for div in doc.css("div") {
            if (div["id"] == "album_info") {
                for _ in div.css("dd") {
                    countTemp = countTemp + 1
                    if countTemp == 7 {
                        break
                    }
                }
            }
        }
        
        // MARK: Parse by DIV
        for div in doc.css("div") {
            if (div["id"] == "album_info") {
                if let a = div.at_css("a") {
                    if let title = a.text {
                        self.title = title
                    }
                    
                    if let urlString = a["href"] {
                        self.urlString = urlString
                        if let id = urlString.components(separatedBy: "/").last {
                            self.id = id
                        }
                    }
                }
                
                if let h2 = div.at_css("h2"), let h2Text = h2.innerHTML {
                    bands = []
                    // In case of split, band names are separated by a /
                    let modifiedH2Text = h2Text.replacingOccurrences(of: " / ", with: "🤘")
                    let listOfTagA = modifiedH2Text.split(separator: "🤘")
                    listOfTagA.forEach { (eachTagA) in
                        if let band = BandLite(from: String(eachTagA)) {
                            bands.append(band)
                        }
                    }
                }
                
                var i = 0
                for dd in div.css("dd") {
                    
                    if (i == 0) {
                        if let releaseType = ReleaseType(typeString: dd.text) {
                            self.type = releaseType
                        }
                    }
                    else if (i == 1) {
                        if let dateString = dd.text {
                            self.dateString = dateString
                        }
                    }
                    else if (i == 2) {
                        if let catalogID = dd.text {
                            self.catalogID = catalogID
                        }
                        
                    }
                    else if (i == 3) {
                        // MARK: Workaround
                        if (countTemp == 7) {
                            if !skipped {
                                skipped = true
                                continue
                            }
                        }
                        
                        // Label
                        if let a = dd.at_css("a") {
                            if let labelURLString = a["href"]?.components(separatedBy: "#").first, let labelName = a.text {
                                self.label = LabelLiteInBand(name: labelName, urlString: labelURLString)
                            }
                        }
                        else {
                            if let labelName = dd.text {
                                self.label = LabelLiteInBand(name: labelName)
                            }
                        }
                    }
                    else if (i == 4) {
                        if let format = dd.text?.replacingOccurrences(of: "\\", with: "") {
                            self.format = format
                        }
                    }
                    else if (i == 5) {
                        
                        if let a = dd.at_css("a") {
                            self.reviewsURLString = a["href"]
                        }
                        
                        var reviewString = dd.text
                        reviewString = reviewString?.replacingOccurrences(of: "\n", with: "")
                        reviewString = reviewString?.replacingOccurrences(of: "\t", with: "")
                        reviewString = "🤘" + (reviewString ?? "")
                        
                        if let reviewString = reviewString,
                            let reviewCountSubstring = reviewString.subString(after: "🤘", before: " review", options: .caseInsensitive),
                            let reviewCount = Int(reviewCountSubstring),
                            let ratingSubstring = reviewString.subString(after: "avg. ", before: "%)", options: .caseInsensitive),
                            let rating = Int(ratingSubstring) {
                            self.reviewCount = reviewCount
                            self.rating = rating
                            
                        } else {
                            self.reviewCount = nil
                            self.rating = nil
                        }
                        
                    }
                    i = i + 1
                }
            }
            
            if (div["id"] == "album_tabs_lineup") {
                let results = Release.parseLineup(div_album_tabs_lineup: div)
                bandMembers = results.bandMembers
                guestSession = results.guestSession
                otherStaff = results.otherStaff
                
                completeLineup = [ArtistLiteInRelease]()
                completeLineup.append(contentsOf: results.bandMembers)
                completeLineup.append(contentsOf: results.guestSession)
                completeLineup.append(contentsOf: results.otherStaff)
            }
            // End of if (div["id"] == "album_tabs_lineup")
            
            if (div["id"] == "album_tabs_notes") {
                self.additionalHTMLNotes = div.innerHTML
            }
            
            if (div["class"] == "album_img") {
                if let a = div.at_css("a"), let coverURLString = a["href"] {
                    self.coverURLString = coverURLString
                }
            }
            
                //Extract "Added on", "Last edited"
            if (div["id"] == "auditTrail") {
                guard let innerHTML = div.innerHTML else { return nil }
                auditTrail = AuditTrail(from: innerHTML)
            }
        }
        
        // MARK: Parse by Table
        self.elements = [ReleaseElement]()
        for table in doc.css("table") {
            if (table["class"] == "display table_lyrics") {
                for tr in table.css("tr") {
                    var elementTitle: String?
                    var elementType: ReleaseElementType?
                    var songLength: String?
                    var songLyricID: String?
                    let isInstrumental = tr.text?.contains("instrumental")
                    if (tr["class"] == "sideRow" || tr["class"] == "discRow") {
                        if let td = tr.at_css("td") {
                            elementTitle = td.text?.replacingOccurrences(of: " ", with: "")
                            if (tr["class"] == "sideRow") {
                                elementTitle = elementTitle?.replacingOccurrences(of: "Side", with: "Side ")
                                elementType = .side
                            }
                            else if (tr["class"] == "discRow") {
                                elementTitle = elementTitle?.replacingOccurrences(of: "Disc", with: "Disc ")
                                elementType = .disc
                            }
                            
                        }
                    }
                    else if (tr["class"] == "odd" || tr["class"] == "even") {
                        // "odd" = chẳn
                        // "even" = lẽ
                        elementType = .song
                        var i = 0
                        for td in tr.css("td") {
                            if (i == 0) {
                                //STT bài hát
                                elementTitle = td.text
                            }
                            else if (i == 1) {
                                //Tên bài hát
                                if var songTitle = td.text, let songOrder = elementTitle {
                                    songTitle = songTitle.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\t", with: "")
                                    elementTitle = "\(songOrder) \(songTitle)"
                                }
                            }
                            else if (i == 2) {
                                //Độ dài
                                songLength = td.text
                            }
                            else if (i == 3) {
                                //Lấy lyricID
                                if let a = td.at_css("a") {
                                    if let lyricID = a["href"] {
                                        songLyricID = lyricID.replacingOccurrences(of: "#", with: "")
                                    }
                                }
                            }
                            
                            i = i + 1
                        }
                    }
                    else if (tr["class"] == "displayNone") {
                        continue
                    }
                    else {
                        //Không có id => thời lượng đĩa
                        elementType = .length
                        var i = 0
                        for td in tr.css("td") {
                            if (i == 1) {
                                elementTitle = td.text
                            }
                            
                            i = i + 1
                        }
                    }
                    
                    elementTitle = elementTitle?.replacingOccurrences(of: "\t", with: "")
                    elementTitle = elementTitle?.replacingOccurrences(of: "\n", with: "")
                    
                    if let `songLength` = songLength, let `elementTitle` = elementTitle {
                        let song = Song(title: elementTitle, length: songLength, lyricID: songLyricID, isInstrumental: isInstrumental)
                        self.elements.append(song)
                    } else if let `elementTitle` = elementTitle, let `elementType` = elementType {
                        let element = ReleaseElement(title: elementTitle, type: elementType)
                        self.elements.append(element)
                    }
                }
                //End of: for tr in table.css("tr")
            }
            //End of: if (table["class"] == "display table_lyrics")
            
            if (self.reviews == nil || self.reviews.count == 0) {
                self.reviews = [ReviewLiteInRelease]()
            }
            
            if (table["id"] == "review_list") {
                var reviewURLString: String?
                var reviewTitle: String?
                var reviewRating: Int?
                var reviewDateString: String?
                var reviewAuthor: UserLite?
                for tr in table.css("tr") {
                    var i = 0
                    for td in tr.css("td") {
                        
                        if (i == 0) {
                            if let a = td.at_css("a") {
                                reviewURLString = a["href"]
                            }
                        }
                        else if (i == 1) {
                            reviewTitle = td.text
                        }
                        else if (i == 2) {
                            if let rating = Int(td.text?.replacingOccurrences(of: "%", with: "") ?? "") {
                                reviewRating = rating
                            }
                        }
                        else if (i == 3) {
                            if let a = td.at_css("a"), let authorName = a.text, let authorURLString = a["href"] {
                                reviewAuthor = UserLite(name: authorName, urlString: authorURLString)
                            }
                        }
                        else if (i == 4) {
                            reviewDateString = td.text
                        }
                        
                        i = i + 1
                    }
                    if let `reviewURLString` = reviewURLString, let `reviewTitle` = reviewTitle, let `reviewRating` = reviewRating, let `reviewAuthor` = reviewAuthor, let `reviewDateString` = reviewDateString {
                        let review = ReviewLiteInRelease(title: reviewTitle, urlString: reviewURLString, rating: reviewRating, author: reviewAuthor, dateString: reviewDateString)
                        self.reviews.append(review)
                    }
                }
            }
            //End of: if (table["id"] == "review_list")
        }
    }
    
    private static func parseLineup(div_album_tabs_lineup: XMLElement) -> (bandMembers: [ArtistLiteInRelease], guestSession: [ArtistLiteInRelease], otherStaff: [ArtistLiteInRelease]) {
        var bandMembers = [ArtistLiteInRelease]()
        var guestSession = [ArtistLiteInRelease]()
        var otherStaff = [ArtistLiteInRelease]()
        
        if let div_album_members = div_album_tabs_lineup.at_css("div") {
            for div in div_album_members.css("div") {
                if (div["id"] == "album_members_lineup") {
                    // Band member
                    bandMembers.append(contentsOf: Release.parseMembers(document: div, lineUpType: .member))
                }
                else if (div["id"] == "album_members_guest") {
                    // Guest/Session
                    guestSession.append(contentsOf: Release.parseMembers(document: div, lineUpType: .guest))
                }
                else if (div["id"] == "album_members_misc") {
                    // Misc.
                    otherStaff.append(contentsOf: Release.parseMembers(document: div, lineUpType: .other))
                }
            }
        }
        
        return (bandMembers, guestSession, otherStaff)
    }
    
    private static func parseMembers(document: XMLElement, lineUpType: LineUpType) -> [ArtistLiteInRelease] {
        var arrayArtists = [ArtistLiteInRelease]()
        var currentBandName: String?
        for tr in document.css("tr") {
            // Workaround
            // In case Split or Original line up
            // Count number of td tag
            // number of td tag == 1 => skip
            
            if tr.css("td").count == 1 {
                // Split or original line up
                // band name here
                currentBandName = tr.at_css("td")?.text
                continue
            }
            
            // End of Workaround
            
            var i = 0
            
            var artistName: String?
            var artistURLString: String?
            var artistAdditionalDetail: String?
            var artistInstrumentString: String?
            
            for td in tr.css("td") {
                
                if (i == 0) {
                    if let a = td.at_css("a") {
                        artistName = a.text
                        artistURLString = a["href"]
                    }
                    if let artistAdditionalDetailSubstring = td.text?.subString(after: "(", before: ")", options: .caseInsensitive) {
                        artistAdditionalDetail = String(artistAdditionalDetailSubstring)
                    }
                }
                else if (i == 1) {
                    artistInstrumentString = td.text
                    artistInstrumentString = artistInstrumentString?.replacingOccurrences(of: "\n", with: "")
                    artistInstrumentString = artistInstrumentString?.replacingOccurrences(of: "\t", with: "")
                }
                
                i = i + 1
            }
            
            
            if let `artistName` = artistName, let `artistURLString` = artistURLString, let `artistInstrumentString` = artistInstrumentString {
                
                if lineUpType != .member {
                    currentBandName = nil
                }
                
                if let artist = ArtistLiteInRelease(name: artistName, urlString: artistURLString, additionalDetail: artistAdditionalDetail, instrumentString: artistInstrumentString, lineUpType: lineUpType, bandName: currentBandName) {
                    arrayArtists.append(artist)
                }
            }
        }
        return arrayArtists
    }
}

// MARK: - Descriptive
extension Release: Descriptive {
    var generalDescription: String {
        return "\(id ?? "") - \(title ?? "") - \(urlString ?? "")"
    }
}

//MARK: - Actionable
extension Release: Actionable {
    var actionableElements: [ActionableElement] {
        var elements: [ActionableElement] = []
        
        self.bands.forEach { (eachBand) in
            let bandElement = ActionableElement.band(name: eachBand.name, urlString: eachBand.urlString)
            elements.append(bandElement)
        }
        
        return elements
    }
    
}
