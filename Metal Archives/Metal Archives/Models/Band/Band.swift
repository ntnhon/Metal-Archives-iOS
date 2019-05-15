//
//  Band.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import Kanna

final class Band: NSObject {
    private(set) var id: String!
    private(set) var name: String!
    private(set) var urlString: String!
    private(set) var country: Country!
    private(set) var genre: String!
    private(set) var status: BandStatus!
    
    private(set) var location: String!
    private(set) var formedIn: String!
    private(set) var yearsActiveString: String!
    private(set) var oldBands: [BandAncient]?
    private(set) var lyricalTheme: String!
    private(set) var lastLabel: LabelLiteInBand!
    private(set) var shortHTMLDescription: String?
    private(set) var completeHTMLDescription: String?
    private(set) var auditTrail: AuditTrail!
    private(set) var logoURLString: String?
    private(set) var photoURLString: String?
    private(set) var discography: Discography? {
        didSet {
            self.findCorrespondingReleasesForReviews()
        }
    }
    
    //Band detail
    private(set) var completeLineup: [ArtistLite]?
    private(set) var currentLineup: [ArtistLite]?
    private(set) var lastKnownLineup: [ArtistLite]?
    private(set) var pastMembers: [ArtistLite]?
    private(set) var liveMusicians: [ArtistLite]?
    lazy var hasNoMember: Bool = {
        return completeLineup == nil
    }()
    
    
    private var didAssociateReleasesToReviews = false
    private(set) var  reviews: [ReviewLite]? {
        didSet {
            if let total = totalReviews, let count = reviews?.count {
                if total == 0 {
                    self.moreToLoad = false
                } else {
                    self.moreToLoad = count < total
                }
            }
        }
    }
    private(set) var totalReviews: Int?
    private(set) var currentReviewsPage: Int = 0
    private(set) var moreToLoad = true
    
    //Similar artist
    private(set) var similarArtists: [BandSimilar]?
    
    private(set) var relatedLinks: [RelatedLink]?
    
    init?(fromData data: Data) {
        
        guard let htmlString = String(data: data, encoding: String.Encoding.utf8),
            let doc = try? Kanna.HTML(html: htmlString, encoding: String.Encoding.utf8) else {
                return nil
        }
        
        for div in doc.css("div") {
            
            //            switch div["id"] {
            //            case "band_info":
            //                guard let results = Band.parseBandInfoDiv(div) else {
            //                    return nil
            //                }
            //                self.name = results.name
            //                self.urlString = results.urlString
            //                self.id = results.id
            //            }
            // Extract band's name and link from div with id = "band_info"
            if (div["id"] == "band_info") {
                guard let results = Band.parseBandInfoDiv(div) else {
                    return nil
                }
                self.name = results.name
                self.urlString = results.urlString
                self.id = results.id
            }
                // Extract band's others detail from div with id = "band_stats"
            else if (div["id"] == "band_stats") {
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
                self.yearsActiveString = results.yearsActiveString
            }
                // Extract band's comment
            else if (div["class"] == "band_comment clear") {
                let prefix = "\n\t    <!-- Max 400 characters. Open the rest in a dialogue box-->\n\t    \t\t    \t"
                self.shortHTMLDescription = div.innerHTML?.replacingOccurrences(of: prefix, with: "")
            }
                
            else if (div["id"] == "auditTrail") {
                guard let innerHTML = div.innerHTML else { return nil }
                self.auditTrail = AuditTrail(from: innerHTML)
            }
                
                //Extract logo and band photo
            else if (div["class"] == "band_name_img") {
                let a = div.at_css("a")
                self.logoURLString = a?["href"]
            }
            else if (div["class"] == "band_img") {
                let a = div.at_css("a")
                self.photoURLString = a?["href"]
            }
                
            else if (div["id"] == "band_tab_members") {
                if let div_band_members = div.at_css("div") {
                    let isLastKnown = div_band_members.text?.range(of: "Last known") != nil

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

extension Band {
    override var description: String {
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
    
    func setReviews(_ reviews: [ReviewLite]?, totalReviews: Int?) {
        self.reviews = reviews
        self.totalReviews = totalReviews
    }
    
    func setSimilarArtists(_ similarArtists: [BandSimilar]?) {
        self.similarArtists = similarArtists
    }
    
    func setRelatedLinks(_ relatedLinks: [RelatedLink]?) {
        self.relatedLinks = relatedLinks
    }
}

extension Band {
    private func findCorrespondingReleasesForReviews() {
        if self.didAssociateReleasesToReviews {
            return
        }
        
        guard let `reviews` = self.reviews, let `discography` = self.discography else { return }
        
        for i in 0..<reviews.count {
            for j in 0..<discography.complete.count {
                if discography.complete[j].title == reviews[i].releaseTitle {
                    reviews[i].associateToRelease(discography.complete[j])
                    break
                }
            }
        }
        
        self.didAssociateReleasesToReviews = true
    }
}

//MARK: - Fetch reviews
extension Band {
    func fetchMoreReviews(onSuccess: @escaping (() -> Void), onError: @escaping ((Error) -> Void)) {
        if !self.moreToLoad {
            return
        }
        self.didAssociateReleasesToReviews = false
        
        let requestReviewsURLString =
        "https://www.metal-archives.com/review/ajax-list-band/id/<BAND_ID>//json/1?sEcho=1&iColumns=4&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=<DISPLAY_LENGTH>&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&iSortCol_0=3&sSortDir_0=desc&iSortingCols=1&bSortable_0=true&bSortable_1=true&bSortable_2=true&bSortable_3=true"
        
        let displayStart = self.currentReviewsPage * 200
        let requestURLString = requestReviewsURLString.replacingOccurrences(of: "<BAND_ID>", with: self.id).replacingOccurrences(of: "<DISPLAY_START>", with: "\(displayStart)").replacingOccurrences(of: "<DISPLAY_LENGTH>", with: "\(200)")
        let requestURL = URL(string: requestURLString)!
        
        RequestHelper.shared.alamofireManager.request(requestURL).responseJSON { [weak self] (response) in
            switch response.result {
            case .success:
                self?.extractReviews(json: response.value as? [String: Any])
                onSuccess()
            case .failure(let error): onError(error)
            }
        }
    }
    
    func extractReviews(json: [String: Any]?){
        var list: [ReviewLite] = []
        
        let totalReviews = json?["iTotalRecords"] as? Int
        if let listReviews = json?["aaData"] as? [[String]] {
            listReviews.forEach { (reviewDetail) in
                let urlString = String(reviewDetail[0].subString(after: "href='", before: "'>", options: .caseInsensitive) ?? "")
                let releaseTitle = String(reviewDetail[0].subString(after: "'>", before: "</a>", options: .caseInsensitive) ?? "")
                let point = Int(reviewDetail[1].replacingOccurrences(of: "%", with: ""))
                let author = String(reviewDetail[2].subString(after: "\">", before: "</a>", options: .caseInsensitive) ?? "")
                let dateString = reviewDetail[3]
                
                
                if let `point` = point {
                    if let review = ReviewLite(urlString: urlString, releaseTitle: releaseTitle, point: point, dateString: dateString, author: author) {
                        list.append(review)
                    }
                } else {
                    #warning("Handle error")
                }
            }
            
            if list.count == 0 {
                return
            }
            
            if self.reviews == nil {
                self.reviews = [ReviewLite]()
            }
            if let `totalReviews` = totalReviews {
                self.totalReviews = totalReviews
            }
            
            self.reviews?.append(contentsOf: list)
            self.findCorrespondingReleasesForReviews()
            self.currentReviewsPage += 1
        } else {
            fatalError("Impossible case!")
        }
    }
}
