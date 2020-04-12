//
//  Band.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import Kanna

final class Band {
    private(set) var id: String!
    private(set) var name: String!
    private(set) var urlString: String!
    private(set) var country: Country!
    private(set) var genre: String!
    private(set) var status: BandStatus!
    
    private(set) var location: String!
    private(set) var formedIn: String!
    private(set) var yearsActiveAttributedString: NSAttributedString!
    private(set) var oldBands: [BandAncient]?
    private(set) var lyricalTheme: String!
    private(set) var lastLabel: LabelLiteInBand!
    private(set) var shortHTMLDescription: String?
    private(set) var completeHTMLDescription: String?
    private(set) var auditTrail: AuditTrail!
    private(set) var logoURLString: String?
    private(set) var photoURLString: String?
    private(set) var discography: Discography?
    
    private(set) var isBookmarked: Bool? = nil
    
    //Band detail
    private(set) var isLastKnown: Bool = false
    private(set) var completeLineup: [ArtistLite]?
    private(set) var currentLineup: [ArtistLite]?
    private(set) var lastKnownLineup: [ArtistLite]?
    private(set) var pastMembers: [ArtistLite]?
    private(set) var liveMusicians: [ArtistLite]?
    
    lazy var completeLineupDescription: String = {
        if let complete = self.completeLineup {
            if complete.count <= 1 {
                return "Complete lineup (\(complete.count) member)"
            } else {
                return "Complete lineup (\(complete.count) members)"
            }
        }
        
        return "Complete lineup (0 member)"
    }()
    lazy var currentLineupDescription: String = {
        if let current = self.currentLineup {
            if current.count <= 1 {
                return "Current lineup (\(current.count) member)"
            } else {
                return "Current lineup (\(current.count) members)"
            }
        }
        
        return "Current lineup (0 member)"
    }()
    lazy var lastKnownLineupDescription: String = {
        if let lastKnown = self.lastKnownLineup {
            if lastKnown.count <= 1 {
                return "Last known lineup (\(lastKnown.count) member)"
            } else {
                return "Last known lineup (\(lastKnown.count) members)"
            }
        }
        
        return "Last known lineup (0 member)"
    }()
    lazy var pastMembersDescription: String = {
        if let pastMembers = self.pastMembers {
            if pastMembers.count <= 1 {
                return "Past members (\(pastMembers.count) member)"
            } else {
                return "Past members (\(pastMembers.count) members)"
            }
        }
        
        return "Past members (0 member)"
    }()
    lazy var liveMusiciansDescription: String = {
        if let liveMusicians = self.liveMusicians {
            if liveMusicians.count <= 1 {
                return "Live musicians (\(liveMusicians.count) member)"
            } else {
                return "Live musicians (\(liveMusicians.count) members)"
            }
        }
        
        return "Live musicians (0 member)"
    }()
    
    lazy var hasNoMember: Bool = {
        return completeLineup == nil
    }()
    
    lazy private(set) var reviewLitePagableManager: PagableManager<ReviewLite> = {
        let manager = PagableManager<ReviewLite>(options: ["<BAND_ID>": self.id])
        return manager
    }()
    
    //Similar artist
    private(set) var similarArtists: [BandSimilar]?
    
    private(set) var relatedLinks: [RelatedLink]?
    
    deinit {
        print("Band is deallocated")
    }
    
    init?(fromData data: Data) {
        
        guard let htmlString = String(data: data, encoding: String.Encoding.utf8),
            let doc = try? Kanna.HTML(html: htmlString, encoding: String.Encoding.utf8) else {
                return nil
        }
        
        // Firstly detect if band is bookmarked or not
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
        
        for div in doc.css("div") {
            
            if let id = div["id"] {
                switch id {
                case "band_info":
                    guard let results = Band.parseBandInfoDiv(div) else {
                        return nil
                    }
                    self.name = results.name
                    self.urlString = results.urlString
                    self.id = results.id
                    
                case "band_stats":
                    guard let results = Band.parseBandStatsDiv(div) else {
                        return nil
                    }
                    
                    self.country = results.country
                    self.location = results.location
                    self.status = results.status
                    self.formedIn = results.formedIn
                    self.genre = results.genre
                    self.lyricalTheme = results.lyricalTheme
                    self.lastLabel = results.lastLabel
                    self.oldBands = results.oldBands
                    self.yearsActiveAttributedString = Band.generateYearsActiveAttributedString(from: results.yearsActiveString, withOldBands: results.oldBands)
                    
                case "auditTrail":
                    guard let innerHTML = div.innerHTML else { return nil }
                    self.auditTrail = AuditTrail(from: innerHTML)
                    
                case "band_tab_members":
                    if let div_band_members = div.at_css("div") {
                        self.isLastKnown = div_band_members.text?.range(of: "Last known") != nil
                        
                        for subDiv in div_band_members.css("div") {
                            
                            if (subDiv["id"] == "band_tab_members_current") {
                                if isLastKnown {
                                    self.lastKnownLineup = Band.parseBandArtists(inDiv: subDiv)
                                }
                                else {
                                    self.currentLineup = Band.parseBandArtists(inDiv: subDiv)
                                }
                                
                            }
                            else if (subDiv["id"] == "band_tab_members_past") {
                                self.pastMembers = Band.parseBandArtists(inDiv: subDiv)
                            }
                            else if (subDiv["id"] == "band_tab_members_live") {
                                self.liveMusicians = Band.parseBandArtists(inDiv: subDiv)
                            }
                        }
                        
                        
                        var completeLineup = [ArtistLite]()
                        
                        if let currentLineup = self.currentLineup {
                            completeLineup.append(contentsOf: currentLineup)
                        }
                        
                        if let lastKnownLineup = self.lastKnownLineup {
                            completeLineup.append(contentsOf: lastKnownLineup)
                        }
                        
                        if let pastMembers = self.pastMembers {
                            completeLineup.append(contentsOf: pastMembers)
                        }
                        
                        if let liveMusicians = self.liveMusicians {
                            completeLineup.append(contentsOf: liveMusicians)
                        }
                        
                        if completeLineup.count == 0 {
                            self.completeLineup = nil
                        } else {
                            self.completeLineup = completeLineup
                        }
                    }
                    
                default: continue
                }
            } else if let `class` = div["class"] {
                switch `class` {
                case "band_comment clear":
                    let prefix = "\n\t    <!-- Max 400 characters. Open the rest in a dialogue box-->\n\t    \t\t    \t"
                    self.shortHTMLDescription = div.innerHTML?.replacingOccurrences(of: prefix, with: "")
                    
                case "band_name_img":
                    let a = div.at_css("a")
                    self.logoURLString = a?["href"]
                    
                case "band_img":
                    let a = div.at_css("a")
                    self.photoURLString = a?["href"]
                    
                default: continue
                }
            }
        }
    }
    
    static func parseBandArtists(inDiv div: XMLElement) -> [ArtistLite]? {
        var artists = [ArtistLite]()
        
        let trs = div.css("tr")
        
        for i in 0..<trs.count {
            // This is the <tr> that contains seeAlsoString, skip when encounter
            if trs[i]["class"] == "lineupBandsRow" {
                continue
            }
            
            // There must be 2 <td>
            // 1st <td> for for artist's name and url
            // 2nd <td> for instruments string
            let tds = trs[i].css("td")
            guard tds.count == 2 else {
                continue
            }
            
            guard let a = tds[0].at_css("a"),
                let urlString = a["href"],
                let name = a.text,
                let instrumentsString = tds[1].text?.removeHTMLTagsAndNoisySpaces() else {
                    continue
            }
            
            // Check the next <tr>, if it's class is "lineupBandsRow" then parse bands and seeAlsoString
            // Use regex to find out A tags
            guard i + 1 < trs.count, trs[i + 1]["class"] == "lineupBandsRow" else {
                if let artist = ArtistLite(urlString: urlString, name: name, instrumentsInBand: instrumentsString, bands: nil, seeAlsoString: nil) {
                    artists.append(artist)
                }
                continue
            }
            
            guard let nextTrInnerHTML = trs[i + 1].innerHTML else {
                continue
            }
            
            var bands = [BandLite]()
            RegexHelpers.listMatches(for: #"<a\s.*?</a>"#, inString: nextTrInnerHTML).forEach { (aTag) in
                if let results = getUrlAndValueFrom(tagA: aTag), let band = BandLite(name: results.value, urlString: results.urlString) {
                    bands.append(band)
                }
            }
            
            let seeAlsoString = nextTrInnerHTML.removeHTMLTagsAndNoisySpaces()
            
            if let artist = ArtistLite(urlString: urlString, name: name, instrumentsInBand: instrumentsString, bands: bands, seeAlsoString: seeAlsoString) {
                artists.append(artist)
            }
        }
        
        if artists.count == 0 {
            return nil
        }
        
        return artists
    }
    
    private static func generateYearsActiveAttributedString(from yearsActiveString: String, withOldBands oldBands: [BandAncient]?) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: yearsActiveString)
        
        attributedString.addAttributes([.foregroundColor: Settings.currentTheme.bodyTextColor, .font: Settings.currentFontSize.bodyTextFont], range: NSRange(yearsActiveString.startIndex..., in: yearsActiveString))
        
        let pastBandNames = RegexHelpers.listGroups(for: #"\(as ([^)]+)\)"#, inString: yearsActiveString)
        
        for oldBandName in pastBandNames {
            let oldBandNameRange = yearsActiveString.range(of: oldBandName)!
            let oldBandNameNSRange = NSRange(oldBandNameRange, in: yearsActiveString)
            
            if let oldBands = oldBands, oldBands.contains(where: {$0.name == oldBandName}) {
                attributedString.addAttributes([.foregroundColor: Settings.currentTheme.secondaryTitleColor, .font: Settings.currentFontSize.secondaryTitleFont], range: oldBandNameNSRange)
            } else {
                attributedString.addAttributes([.foregroundColor: Settings.currentTheme.bodyTextColor, .font: Settings.currentFontSize.secondaryTitleFont], range: oldBandNameNSRange)
            }
        }
        
        return attributedString
    }
}

//MARK: - Parse band's details by divs
extension Band {
    /*
     Sample data:
     <div id="band_info">
     
     <h1 class="band_name"><a href="https://www.metal-archives.com/bands/Death/141">Death</a></h1>
     
     
     <div class="clear block_spacer_5"></div>
     */
    
    fileprivate static func parseBandInfoDiv(_ div: XMLElement) -> (name: String, urlString: String, id: String)? {
        guard let a = div.at_css("a"), let bandName = a.text, let urlString = a["href"] else { return nil
        }
        
        guard let id = urlString.components(separatedBy: "/").last else {
            return nil
        }
        
        return (bandName, urlString, id)
    }
    
    /*
     Sample data:
     <div id="band_stats">
     <dl class="float_left">
     <dt>Country of origin:</dt>
     <dd><a href="https://www.metal-archives.com/lists/US">United States</a></dd>
     <dt>Location:</dt>
     <dd>Altamonte Springs, Florida</dd>
     <dt>Status:</dt>
     <dd class="split_up">Split-up</dd>
     <dt>Formed in:</dt>
     <dd>1984</dd>
     </dl>
     <dl class="float_right">
     <dt>Genre:</dt>
     <dd>Death Metal (early), Death/Progressive Metal (later)</dd>
     <dt>Lyrical themes:</dt>
     <dd>Death, Gore (early); Society, Enlightenment (later)</dd>
     <dt>Last label:</dt>
     <dd><a href="https://www.metal-archives.com/labels/Nuclear_Blast/2">Nuclear Blast</a></dd>
     </dl>
     <dl style="width: 100%;" class="clear">
     <dt>Years active:</dt>
     <dd>
     
     1983-1984                                (as <a href="https://www.metal-archives.com/bands/Mantas/35328">Mantas</a>),
     1984-2001                                    </dd>
     </dl>
     </div>
     */
    fileprivate static func parseBandStatsDiv(_ div: XMLElement) -> (country: Country, location: String, status: BandStatus, formedIn: String, genre: String, lyricalTheme: String, lastLabel: LabelLiteInBand, oldBands: [BandAncient]?, yearsActiveString: String)? {
        
        var country: Country?
        var location: String?
        var status: BandStatus?
        var formedIn: String?
        var genre: String?
        var lyricalTheme: String?
        var lastLabel: LabelLiteInBand?
        var oldBands: [BandAncient]?
        var yearsActiveString: String?
        
        var i = 0
        let dds = div.css("dd")
        for dt in div.css("dt") {
            defer { i += 1}
            
            guard let dtText = dt.text else { continue }
            
            if dtText.contains("Country") {
                if let a = dds[i].at_css("a"), let countryUrlString = a["href"], let countryISO = countryUrlString.components(separatedBy: "/").last {
                    country = Country(iso: countryISO)
                }
                continue
            }
            
            if dtText.contains("Location") {
                location = dds[i].text
                continue
            }
            
            if dtText.contains("Status") {
                if let statusString = dds[i].text {
                    status = BandStatus(statusString: statusString)
                }
                continue
            }
            
            if dtText.contains("Formed") {
                formedIn = dds[i].text
                continue
            }
            
            if dtText.contains("Genre") {
                genre = dds[i].text
                continue
            }
            
            if dtText.contains("Lyrical") {
                lyricalTheme = dds[i].text
                continue
            }
            
            if dtText.contains("label") {
                if let a = dds[i].at_css("a"), let labelName = a.text {
                    if let labelUrlString = a["href"] {
                        lastLabel = LabelLiteInBand(name: labelName, urlString: labelUrlString)
                    }
                } else if let labelName = dds[i].text {
                    lastLabel = LabelLiteInBand(name: labelName)
                }
                continue
            }
            
            if dtText.contains("Years") {
                if let results = Band.parseOldBandsAndYearsActiveString(dds[i]) {
                    oldBands = results.oldBands
                    yearsActiveString = results.yearsActiveString
                }
                continue
            }
            
        }
        
        if let country = country, let location = location, let status = status, let formedIn = formedIn, let genre = genre, let lyricalTheme = lyricalTheme, let lastLabel = lastLabel, let yearsActiveString = yearsActiveString {
            return (country, location, status, formedIn, genre, lyricalTheme, lastLabel, oldBands, yearsActiveString)
        }
        
        return nil
    }
    
    fileprivate static func parseOldBandsAndYearsActiveString(_ div: XMLElement) -> (oldBands: [BandAncient]?, yearsActiveString: String)? {
        
        guard let rawTextString = div.innerHTML else { return nil }
        
        var oldBands = [BandAncient]()
        
        // Use regex to find out A tags
        RegexHelpers.listMatches(for: #"<a\s.*?</a>"#, inString: rawTextString).forEach { (aTag) in
            if let results = getUrlAndValueFrom(tagA: aTag) {
                oldBands.append(.init(name: results.value, urlString: results.urlString))
            }
        }
        
        let yearsActiveString = rawTextString.removeHTMLTagsAndNoisySpaces()
        
        if oldBands.count == 0 {
            return (nil, yearsActiveString)
        }
        
        return (oldBands, yearsActiveString)
    }
}

// MARK: - Descriptive
extension Band: Descriptive {
    var generalDescription: String {
        return "\(self.id ?? "") - \(self.name ?? "") - \(self.country.nameAndEmoji)"
    }
}

extension Band {
    func setReadMoreString(_ readMoreString: String) {
        self.completeHTMLDescription = readMoreString
    }
    
    func setDiscography(_ discography: Discography?) {
        self.discography = discography
    }
    
    func setSimilarArtists(_ similarArtists: [BandSimilar]?) {
        self.similarArtists = similarArtists
    }
    
    func setRelatedLinks(_ relatedLinks: [RelatedLink]?) {
        self.relatedLinks = relatedLinks
    }
    
    func associateReleasesToReviews() {
        guard let discography = discography else { return }
        for review in reviewLitePagableManager.objects {
            if let _ = review.release {
                continue
            }
            
            for release in discography.complete {
                if release.title == review.releaseTitle {
                    review.associateToRelease(release)
                    break
                }
            }
        }
    }
    
    func setIsBookmarked(_ isBookmarked: Bool) {
        self.isBookmarked = isBookmarked
    }
}
