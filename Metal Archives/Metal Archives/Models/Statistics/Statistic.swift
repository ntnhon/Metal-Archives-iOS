//
//  Statistic.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import Kanna

final class Statistic {
    let dateAndTimeString: String
    let band: BandStatistic
    let review: ReviewStatistic
    let label: LabelStatistic
    let artist: ArtistStatistic
    let member: MemberStatistic
    let release: ReleaseStatistic
    
    init(dateAndTimeString: String, band: BandStatistic, review: ReviewStatistic, label: LabelStatistic, artist: ArtistStatistic, member: MemberStatistic, release: ReleaseStatistic) {
        self.dateAndTimeString = dateAndTimeString
        self.band = band
        self.review = review
        self.label = label
        self.artist = artist
        self.member = member
        self.release = release
    }
    
    convenience init?(fromData data: Data) {
        var dateAndTimeString: String?
        var bandStatistic: BandStatistic?
        var reviewStatistic: ReviewStatistic?
        var labelStatistic: LabelStatistic?
        var artistStatistic: ArtistStatistic?
        var memberStatistic: MemberStatistic?
        var releaseStatistic: ReleaseStatistic?
        
        guard let htmlString = String(data: data, encoding: String.Encoding.utf8),
            let doc = try? Kanna.HTML(html: htmlString, encoding: String.Encoding.utf8) else {
                return nil
        }
        
        
        for div in doc.css("div") {
            if div["class"] == "ui-tabs-panel-content" {
                
                let ps = div.css("p")
                
                for i in 0..<ps.count {
                    if i == 0 {
                        dateAndTimeString = Statistic.parseDateAndTimeString(p: ps[i])
                    } else if i == 1 {
                        bandStatistic = Statistic.parseBandStatistic(p: ps[i])
                    } else if i == 2 {
                        reviewStatistic = Statistic.parseReviewStatistic(p: ps[i])
                    } else if i == 3 {
                        labelStatistic = Statistic.parseLabelStatistic(p: ps[i])
                    } else if i == 4 {
                        artistStatistic = Statistic.parseArtistStatistic(p: ps[i])
                    } else if i == 5 {
                        memberStatistic = Statistic.parseMemberStatistic(p: ps[i])
                    } else if i == 6 {
                        releaseStatistic = Statistic.parseReleaseStatistic(p: ps[i])
                    }
                }
                
                break
            }
        }
        
        
        if let `dateAndTimeString` = dateAndTimeString,
            let `bandStatistic` = bandStatistic,
            let `reviewStatistic` = reviewStatistic,
            let `labelStatistic` = labelStatistic,
            let `artistStatistic` = artistStatistic,
            let `memberStatistic` = memberStatistic,
            let `releaseStatistic` = releaseStatistic {
            self.init(dateAndTimeString: dateAndTimeString, band: bandStatistic, review: reviewStatistic, label: labelStatistic, artist: artistStatistic, member: memberStatistic, release: releaseStatistic)
        } else {
            return nil
        }
    }
}

extension Statistic {
    private static func parseDateAndTimeString(p: XMLElement) -> String? {
        //<p class="center">Stats as of February 27th, 2019, 2:02 am EST</p>
        return p.text
    }
    
    private static func parseBandStatistic(p: XMLElement) -> BandStatistic? {
        /*
         <p>
         There is a total of <strong>127161</strong> <a href="https://www.metal-archives.com/archives/band-list/by/created">approved bands</a>.
         <span class="active">71134</span> are active, <span class="on_hold">2942</span> are on hold, <span class="split_up">40520</span> are split-up, <span class="changed_name">5457</span> changed name, and the rest (<span class="unknown">7094</span> bands) are unknown.
         </p>
         */
        
        var total: Int?
        var active: Int?
        var onHold: Int?
        var splitUp: Int?
        var changedName: Int?
        var unknown: Int?
        
        //Total
        if let strong = p.at_css("strong"), let strongString = strong.text {
            total = Int(strongString)
        }
        
        let spans = p.css("span")
        
        spans.forEach { (span) in
            let spanClassName = span["class"]
            if spanClassName == "active" {
                if let activeString = span.text {
                    active = Int(activeString)
                }
            } else if spanClassName == "on_hold" {
                if let onHoldString = span.text {
                    onHold = Int(onHoldString)
                }
            } else if spanClassName == "split_up" {
                if let splitUpString = span.text {
                    splitUp = Int(splitUpString)
                }
            } else if spanClassName == "changed_name" {
                if let changedNameString = span.text {
                    changedName = Int(changedNameString)
                }
            } else if spanClassName == "unknown" {
                if let unknownString = span.text {
                    unknown = Int(unknownString)
                }
            }
        }

        
        if let `total` = total,
            let `active` = active,
            let `onHold` = onHold,
            let `splitUp` = splitUp,
            let `changedName` = changedName,
            let `unknown` = unknown {
            return BandStatistic(total: total, active: active, onHold: onHold, splitUp: splitUp, changedName: changedName, unknown: unknown)
        } else {
            return nil
        }
    }
    
    private static func parseReviewStatistic(p: XMLElement) -> ReviewStatistic? {
        /*
         <p>
         There is a total of <strong>101615</strong> <a href="https://www.metal-archives.com/review/browse">approved reviews</a>, for <strong>48025</strong> unique albums.
         </p>
         */
        var approvedReviews: Int?
        var uniqueAlbum: Int?
        
        let strongs = p.css("strong")
        
        for i in 0..<strongs.count {
            if i == 0 {
                if let approvedReviewsString = strongs[i].text {
                    approvedReviews = Int(approvedReviewsString)
                }
            } else if i == 1 {
                if let uniqueAlbumString = strongs[i].text {
                    uniqueAlbum = Int(uniqueAlbumString)
                }
            }
        }
        
        if let `approvedReviews` = approvedReviews,
            let `uniqueAlbum` = uniqueAlbum {
            return ReviewStatistic(approvedReviews: approvedReviews, uniqueAlbum: uniqueAlbum)
        } else {
            return nil
        }
    }
    
    private static func parseLabelStatistic(p: XMLElement) -> LabelStatistic? {
        /*
         <p>
         There is a total of <strong>34196</strong> <a href="https://www.metal-archives.com/label">labels</a>. <span class="active">14502</span> are active, <span class="closed">11419</span> are closed, <span class="changed_name">267</span> changed name, and the rest (<span class="unknown">7872</span> labels) are unknown.
         </p>
         */
        var total: Int?
        var active: Int?
        var closed: Int?
        var changedName: Int?
        var unknown: Int?
        
        
        //Total
        if let strong = p.at_css("strong"), let strongString = strong.text {
            total = Int(strongString)
        }
        
        let spans = p.css("span")
        
        spans.forEach { (span) in
            let spanClassName = span["class"]
            if spanClassName == "active" {
                if let activeString = span.text {
                    active = Int(activeString)
                }
            } else if spanClassName == "closed" {
                if let closedString = span.text {
                    closed = Int(closedString)
                }
            } else if spanClassName == "changed_name" {
                if let changedNameString = span.text {
                    changedName = Int(changedNameString)
                }
            } else if spanClassName == "unknown" {
                if let unknownString = span.text {
                    unknown = Int(unknownString)
                }
            }
        }
        
        if let `total` = total, let `active` = active, let `closed` = closed, let `changedName` = changedName, let `unknown` = unknown {
            return LabelStatistic(total: total, active: active, closed: closed, changedName: changedName, unknown: unknown)
        } else {
            return nil
        }
    }
    
    private static func parseArtistStatistic(p: XMLElement) -> ArtistStatistic? {
        /*
         <p>
         There is a total of <strong>677096</strong> artists. 554146 are still playing. 122950 quit playing music / metal. 4677 are deceased. 44044 are female, 627881 are male, 5128 are unknown or entities (such as orchestras).
         </p>
         */
        
        var total: Int?
        var stillPlaying: Int?
        var quitPlaying: Int?
        var deceased: Int?
        var female: Int?
        var male: Int?
        var unknownOrEntities: Int?
        
        //Total
        if let strong = p.at_css("strong"), let strongString = strong.text {
            total = Int(strongString)
        }
        
        if let rawString = p.innerHTML {
            if let stillPlayStringSubString = rawString.subString(after: "artists. ", before: " are still", options: .caseInsensitive) {
                stillPlaying = Int(stillPlayStringSubString)
            }
            
            if let quiPlayingSubString = rawString.subString(after: "playing. ", before: " quit playing", options: .caseInsensitive) {
                quitPlaying = Int(quiPlayingSubString)
            }
            
            if let deceasesSubString = rawString.subString(after: "music / metal. ", before: " are deceased", options: .caseInsensitive) {
                deceased = Int(deceasesSubString)
            }
            
            if let femaleSubString = rawString.subString(after: "deceased. ", before: " are female", options: .caseInsensitive) {
                female = Int(femaleSubString)
            }
            
            if let maleSubString = rawString.subString(after: "are female, ", before: " are male", options: .caseInsensitive) {
                male = Int(maleSubString)
            }
            
            if let unknownOrEntitiesSubString = rawString.subString(after: "are male, ", before: " are unknown", options: .caseInsensitive) {
                unknownOrEntities = Int(unknownOrEntitiesSubString)
            }
        }
        
        if let `total` = total, let `stillPlaying` = stillPlaying, let `quitPlaying` = quitPlaying, let `deceased` = deceased, let `female` = female, let `male` = male, let `unknownOrEntities` = unknownOrEntities {
            return ArtistStatistic(total: total, stillPlaying: stillPlaying, quitPlaying: quitPlaying, deceased: deceased, female: female, male: male, unknownOrEntities: unknownOrEntities)
        } else {
            return nil
        }
    }
    
    private static func parseMemberStatistic(p: XMLElement) -> MemberStatistic? {
        /*
         <p>
         There are 394166 <a href="https://www.metal-archives.com/user/list">active members</a>, 141205 inactive members for a total of <strong>535371</strong> registered members.
         </p>
         */
        var total: Int?
        var active: Int?
        var inactive: Int?
        
        if let rawString = p.innerHTML {
            if let activeSubString = rawString.subString(after: "There are ", before: " <a href", options: .caseInsensitive) {
                active = Int(activeSubString)
            }
            
            if let inactiveSubString = rawString.subString(after: "</a>, ", before: " inactive", options: .caseInsensitive) {
                inactive = Int(inactiveSubString)
            }
        }
        
        if let strong = p.at_css("strong"), let totalString = strong.text {
            total = Int(totalString)
        }
        
        if let `total` = total, let `active` = active, let `inactive` = inactive {
            return MemberStatistic(total: total, active: active, inactive: inactive)
        } else {
            return nil
        }
    }
    
    private static func parseReleaseStatistic(p: XMLElement) -> ReleaseStatistic? {
        /*
         <p>
         There is a total of <strong>359800</strong> albums and <strong>2572597</strong> songs.
         </p>
         */
        var albums: Int?
        var songs: Int?
        
        let strongs = p.css("strong")
        for i in 0..<strongs.count {
            if i == 0 {
                if let albumsString = strongs[i].text {
                    albums = Int(albumsString)
                }
            }
            
            if i == 1 {
                if let songsString = strongs[i].text {
                    songs = Int(songsString)
                }
            }
        }
        
        if let `albums` = albums, let `songs` = songs {
            return ReleaseStatistic(albums: albums, songs: songs)
        } else {
            return nil
        }
    }
}
