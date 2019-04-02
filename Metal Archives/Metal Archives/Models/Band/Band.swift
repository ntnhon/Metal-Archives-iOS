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
    private(set) var  name: String!
    private(set) var  urlString: String!
    private(set) var  country: Country!
    private(set) var  genre: String!
    private(set) var  status: BandStatus!
    
    private(set) var  location: String!
    private(set) var  formedIn: String!
    private(set) var  yearsActiveString: String!
    private(set) var  oldBands: [BandAncient]?
    private(set) var  lyricalTheme: String!
    private(set) var  lastLabel: LabelLiteInBand!
    private(set) var  shortHTMLDescription: String?
    private(set) var  completeHTMLDescription: String?
    private(set) var  addedOnDate: Date?
    private(set) var  lastModifiedOnDate: Date?
    private(set) var  logoURLString: String?
    private(set) var  photoURLString: String?
    private(set) var  discography: Discography? {
        didSet {
            self.findCorrespondingReleasesForReviews()
        }
    }
    
    //Band detail
    private(set) var  completeLineup: [ArtistLite]?
    private(set) var  currentLineup: [ArtistLite]?
    private(set) var  lastKnownLineup: [ArtistLite]?
    private(set) var  pastMembers: [ArtistLite]?
    private(set) var  liveMusicians: [ArtistLite]?
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
    private(set) var  similarArtists: [BandSimilar]?
    
    private(set) var relatedLinks: [RelatedLink]?
    
    init?(fromData data: Data) {
        
        guard let htmlString = String(data: data, encoding: String.Encoding.utf8),
            let doc = try? Kanna.HTML(html: htmlString, encoding: String.Encoding.utf8) else {
                return nil
        }
        
        for div in doc.css("div") {
            // Extract band's name and link from div with id = "band_info"
            if (div["id"] == "band_info") {
                if let a = div.at_css("a"), let bandName = a.text, let urlString = a["href"] {
                    self.name = bandName
                    self.urlString = urlString
                } else {
                    #warning("Handle error")
                    return nil
                }
                
                if let id = self.urlString.components(separatedBy: "/").last {
                    self.id = id
                } else {
                    #warning("Handle error")
                    return nil
                }
                
            }
                // Extract band's others detail from div with id = "band_stats"
            else if (div["id"] == "band_stats") {
                var i = 0
                for dd in div.css("dd") {
                    
                    if (i == 0) {
                        // Country of origin
                        if let a = dd.at_css("a"), let countryURLString = a["href"],
                            let countryISO = countryURLString.components(separatedBy: "/").last,
                            let country = Country(iso: countryISO) {
                                self.country = country
                            
                        } else {
                            #warning("Handle error")
                            return nil
                        }
                    }
                    else if (i == 1) {
                        // Location
                        location = dd.text!
                    }
                    else if (i == 2) {
                        //Status
                        if let statusString = dd.text {
                            status = BandStatus(statusString: statusString)
                        }
                        
                    }
                    else if (i == 3) {
                        //Formed in
                        formedIn = dd.text!
                    }
                    else if (i == 4) {
                        //Genre
                        genre = dd.text!
                    }
                    else if (i == 5) {
                        //Lyrical themes
                        self.lyricalTheme = dd.text!
                    }
                    else if (i == 6) {
                        //Label
                        if let a = dd.at_css("a") {
                            if let labelName = a.text, let labelURLString = a["href"] {
                                self.lastLabel = LabelLiteInBand(name: labelName, urlString: labelURLString)
                            }
                            
                        }
                        else {
                            if let labelName = dd.text {
                                self.lastLabel = LabelLiteInBand(name: labelName, urlString: nil)
                            }
                        }
   
                    }
                    else if (i == 7) {
                        
                        //Change all "strong" tag to "a" tag
                        let yearsActiveHTML = dd.innerHTML?.replacingOccurrences(of: "strong", with: "a")
                        
                        if let yearsActiveDoc = try? Kanna.HTML(html: yearsActiveHTML!, encoding: String.Encoding.utf8) {
                            
                            self.oldBands = [BandAncient]()
                            for a in yearsActiveDoc.css("a") {
                                if let ancientBandURLString = a["href"],
                                    let ancientBandName = a.text {
                                    
                                    let ancientBand = BandAncient(name: ancientBandName, urlString: ancientBandURLString)
                                    self.oldBands?.append(ancientBand)
                                }
                            }
                            
                        }
                        
                        var yearsActiveString = dd.text
                        yearsActiveString = yearsActiveString?.replacingOccurrences(of: "\n", with: "")
                        yearsActiveString = yearsActiveString?.replacingOccurrences(of: "\t", with: "")
                        yearsActiveString = yearsActiveString?.replacingOccurrences(of: " ", with: "")
                        yearsActiveString = yearsActiveString?.replacingOccurrences(of: ",", with: ", ")
                        yearsActiveString = yearsActiveString?.replacingOccurrences(of: "(", with: " (")
                        yearsActiveString = yearsActiveString?.replacingOccurrences(of: "(as", with: "(as ")
                        
                        if let `yearsActiveString` = yearsActiveString {
                            if let oldBands = self.oldBands {
                                if oldBands.count > 0 {
                                    self.yearsActiveString = Band.generateYearsActiveString(yearsActiveBand: oldBands, yearsActiveString: yearsActiveString)
                                } else {
                                    self.yearsActiveString = yearsActiveString
                                }
                            } else {
                                self.yearsActiveString = yearsActiveString
                            }
                        } else {
                            #warning("Handle error")
                            return nil
                        }
                        
                        if self.oldBands?.count == 0 {
                            self.oldBands = nil
                        }
                    }
                    
                    i = i + 1
                }
            }
                // Extract band's comment
            else if (div["class"] == "band_comment clear") {
                let prefix = "\n\t    <!-- Max 400 characters. Open the rest in a dialogue box-->\n\t    \t\t    \t"
                self.shortHTMLDescription = div.innerHTML?.replacingOccurrences(of: prefix, with: "")
            }
                
                //Extract "Added on", "Last edited"
            else if (div["id"] == "auditTrail") {
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
                    var isLastKnown = false
                    
                    if let _ = div_band_members.text?.range(of: "Last known") {
                        isLastKnown = true
                    }
                    
                    
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
    
    private static func generateYearsActiveString(yearsActiveBand: [BandAncient], yearsActiveString: String) -> String {
        var yearsActiveStringComponents = yearsActiveString.components(separatedBy: CharacterSet(charactersIn: "()"))
        //Replace ancient band name correctly
        for i in 0...yearsActiveBand.count-1 {
            let ancientBand = yearsActiveBand[i] as BandAncient
            
            yearsActiveStringComponents[i*2+1] = "(as \(ancientBand.name))"
            
        }
        
        var returnString = ""
        
        for i in 0...yearsActiveStringComponents.count-1 {
            returnString = returnString.appending(yearsActiveStringComponents[i])
        }
        
        return returnString
    }
    
    private static func parseBandArtists(inDiv div: XMLElement) -> [ArtistLite]? {
        var arrayArtists = [ArtistLite]()
        
        if let table = div.at_css("table") {
            for tr in table.css("tr") {
                if (tr["class"] == "lineupHeaders") {
                    continue
                }
                
                if (tr["class"] == "lineupRow") {
                    var name: String?
                    var urlString: String?
                    var instrumentsInBandString: String?
                    
                    var i = 0
                    for td in tr.css("td") {
                        if (i == 0) {
                            if let a = td.at_css("a") {
                                name = a.text
                                urlString = a["href"]
                            }
                        }
                        else if (i == 1) {
                            instrumentsInBandString = td.text
                            instrumentsInBandString = instrumentsInBandString?.replacingOccurrences(of: "&nbsp;", with: " ")
                            instrumentsInBandString = instrumentsInBandString?.replacingOccurrences(of: "\n", with: "")
                            instrumentsInBandString = instrumentsInBandString?.replacingOccurrences(of: "\t", with: "")
                        }
                        
                        i = i + 1
                    }
                    
                    
                    if let `urlString` = urlString, let `name` = name, let `instrumentsInBandString` = instrumentsInBandString {
                        if let artist = ArtistLite(urlString: urlString, name: name, instrumentsInBand: instrumentsInBandString) {
                            arrayArtists.append(artist)
                        }
                        
                    } else {
                        #warning("Handle error")
                    }
                   
                }
                    
                else if (tr["class"] == "lineupBandsRow") {
                    let artist = arrayArtists[arrayArtists.count-1]
                    
                    if let td = tr.at_css("td") {
                        var seeAlsoString = td.text
                        seeAlsoString = seeAlsoString?.replacingOccurrences(of: "\t", with: "")
                        seeAlsoString = seeAlsoString?.replacingOccurrences(of: "\n", with: "")
                        
                        //Work around for case: " (R.I.P 2015)See also"
                        seeAlsoString = seeAlsoString?.replacingOccurrences(of: "See also:", with: "See also: ")
                        seeAlsoString = seeAlsoString?.replacingOccurrences(of: ")See", with: ") See")
                        
                        if var stringTemp = seeAlsoString {
                            if stringTemp.count > 0 && stringTemp[0] == " " {
                                stringTemp.remove(at: stringTemp.startIndex)
                                seeAlsoString = stringTemp
                            }
                        }
                        
                        artist.setSeeAlsoString(seeAlsoString)
                    }
                    
                    var bands = [BandLite]()
                    
                    for a in tr.css("a") {
                        let bandName = a.text
                        let bandURLString = a["href"]
                        
                        if let `bandName` = bandName, let `bandURLString` = bandURLString {
                            if let band = BandLite(name: bandName, urlString: bandURLString) {
                                bands.append(band)
                                artist.setBands(bands)
                            }
                        }
                    }
                }
            }
        }
        
        if arrayArtists.count == 0 {
            return nil
        }
        
        return arrayArtists
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
