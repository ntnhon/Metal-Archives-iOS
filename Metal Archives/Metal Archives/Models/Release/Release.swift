//
//  Release.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 05/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import Kanna

final class Release {
    private(set) var id: String!
    private(set) var urlString: String!
    private(set) var band: BandLite?
    private(set) var coverURLString: String?
    private(set) var reviewsURLString: String?
    private(set) var title: String!
    private(set) var type: ReleaseType!
    private(set) var dateString: String!
    private(set) var catalogID: String!
    private(set) var label: LabelLiteInBand!
    private(set) var format: String!
    private(set) var additionalHTMLNotes: String?
    private(set) var ratingString: String!
    private(set) var rating: Int?
    private(set) var addedOnDate: Date!
    private(set) var lastModifiedOnDate: Date!
    
    private(set) var elements: [ReleaseElement]!
    private(set) var lineUp: [ArtistLiteInRelease]!
    private(set) var reviews: [ReviewLiteInRelease]!
    private(set) var otherVersions: [ReleaseOtherVersion]!
    
    func setOtherVersions(_ otherVersions: [ReleaseOtherVersion]) {
        self.otherVersions = otherVersions
    }
//    
//    override var description: String {
//        return "\(self.id ?? "") - \(self.title ?? "") - \(self.urlString ?? "")"
//    }
    
    init?(data: Data) {
        guard let htmlString = String(data: data, encoding: String.Encoding.utf8),
            let doc = try? Kanna.HTML(html: htmlString, encoding: String.Encoding.utf8) else {
                return nil
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
                
                if let h2 = div.at_css("h2") {
                    if let a = h2.at_css("a") {
                        if let bandName = a.text, let bandURLString = a["href"] {
                            self.band = BandLite(name: bandName, urlString: bandURLString)
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
                        reviewString = reviewString?.replacingOccurrences(of: " ", with: "")
                        
                        if (reviewString != "Noneyet") {
                            reviewString = reviewString?.replacingOccurrences(of: "re", with: " re")
                            reviewString = reviewString?.replacingOccurrences(of: "avg.", with: "avg. ")
                            reviewString = reviewString?.replacingOccurrences(of: "(", with: " (")
                            reviewString = reviewString?.replacingOccurrences(of: "co", with: " co")
                            self.ratingString = reviewString ?? ""
                            
                            if let ratingSubString = self.ratingString.subString(after: "avg. ", before: "%)", options: .caseInsensitive) {
                                self.rating = Int(String(ratingSubString))
                            }
                        }
                        else {
                            self.ratingString = "None yet"
                        }
                        
                    }
                    i = i + 1
                }
            }
            
            if (div["id"] == "album_tabs_lineup") {
                self.lineUp = Release.parseLineup(div_album_tabs_lineup: div)
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
                //2019-01-29 04:29:49
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                var i = 0
                for td in div.css("td") {
                    if (i == 2) {
                        if let addedOnString = (td.text?.replacingOccurrences(of: "Added on: ", with: "")),
                            let addedOnDate =  dateFormatter.date(from: addedOnString) {
                            self.addedOnDate = addedOnDate
                        } else {
                            self.addedOnDate = nil
                        }
                    }
                    else if (i == 3) {
                        if let lastModifiedOnString = (td.text?.replacingOccurrences(of: "Last modified on: ", with: "")),
                            let lastModifiedOnDate = dateFormatter.date(from: lastModifiedOnString) {
                            self.lastModifiedOnDate = lastModifiedOnDate
                        } else {
                            self.lastModifiedOnDate = nil
                        }
                        
                        break
                    }
                    
                    i = i + 1
                }
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
                        let song = Song(title: elementTitle, length: songLength, lyricID: songLyricID)
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
                var reviewAuthor: String?
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
                            if let a = td.at_css("a") {
                                reviewAuthor = a.text
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
    
    private static func parseLineup(div_album_tabs_lineup: XMLElement) -> [ArtistLiteInRelease] {
        var arrayArtists = [ArtistLiteInRelease]()
        
        if let div_album_members = div_album_tabs_lineup.at_css("div") {
            for div in div_album_members.css("div") {
                if (div["id"] == "album_members_lineup") {
                    // Band's member
                    arrayArtists.append(contentsOf: Release.parseMembers(document: div, lineUpType: .member))
                }
                else if (div["id"] == "album_members_guest") {
                    // Guest/Session
                    arrayArtists.append(contentsOf: Release.parseMembers(document: div, lineUpType: .guest))
                }
                else if (div["id"] == "album_members_misc") {
                    // Misc.
                    arrayArtists.append(contentsOf: Release.parseMembers(document: div, lineUpType: .other))
                }
            }
        }
        
        return arrayArtists
    }
    
    private static func parseMembers(document: XMLElement, lineUpType: LineUpType) -> [ArtistLiteInRelease] {
        var arrayArtists = [ArtistLiteInRelease]()
        
        for tr in document.css("tr") {
            // Workaround
            // In case Split or Original line up
            //Count number of td tag
            // number of td tag == 1 => skip
            var j = 0
            for _ in tr.css("td") {
                j = j + 1
            }
            
            if (j == 1) {
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
                    artistAdditionalDetail = td.text
                    artistAdditionalDetail = artistAdditionalDetail?.replacingOccurrences(of: "\n", with: "")
                    artistAdditionalDetail = artistAdditionalDetail?.replacingOccurrences(of: "\t", with: "")
                    
                    //                    if (artistAdditionalDetail?.rangeOfString(artist.name!) == nil) {
                    //                        artist.forDiscAdditionalDetail = additionalDetailString
                    //                    }
                    //                    else {
                    //                        artist.forDiscAdditionalDetail = ""
                    //                    }
                }
                else if (i == 1) {
                    artistInstrumentString = td.text
                    artistInstrumentString = artistInstrumentString?.replacingOccurrences(of: "\n", with: "")
                    artistInstrumentString = artistInstrumentString?.replacingOccurrences(of: "\t", with: "")
                }
                
                i = i + 1
            }
            
            
            if let `artistName` = artistName, let `artistURLString` = artistURLString, let `artistInstrumentString` = artistInstrumentString {
                if let artist = ArtistLiteInRelease(name: artistName, urlString: artistURLString, additionalDetail: artistAdditionalDetail, instrumentString: artistInstrumentString, lineUpType: lineUpType) {
                    arrayArtists.append(artist)
                }
            }
        }
        return arrayArtists
    }
}
