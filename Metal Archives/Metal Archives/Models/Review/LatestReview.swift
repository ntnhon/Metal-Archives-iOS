//
//  LatestReview.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 15/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class LatestReview: Thumbnailable {
    let dateString: String
    let reviewURLString: String
    let band: BandLite
    let release: ReleaseExtraLite
    let rating: Int
    let timeString: String
    let author: String
    
    init?(dateString: String, reviewURLString: String, band: BandLite, release: ReleaseExtraLite, rating: Int, timeString: String, author: String) {
        self.dateString = dateString
        self.reviewURLString = reviewURLString
        self.band = band
        self.release = release
        self.rating = rating
        self.timeString = timeString
        self.author = author
        super.init(urlString: release.urlString, imageType: .release)
    }
}

//MARK: - Pagable
extension LatestReview: Pagable {
    static var rawRequestURLString = "https://www.metal-archives.com/review/ajax-list-browse/by/date/selection/<YEAR_MONTH>?sEcho=3&iColumns=7&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=200&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&mDataProp_4=4&mDataProp_5=5&mDataProp_6=6&iSortCol_0=6&sSortDir_0=desc&iSortingCols=1&bSortable_0=true&bSortable_1=false&bSortable_2=true&bSortable_3=false&bSortable_4=true&bSortable_5=true&bSortable_6=true&_=1550957396237"
    static var displayLenght = 200
    
    static func parseListFrom(data: Data) -> (objects: [LatestReview]?, totalRecords: Int?)? {
        var list: [LatestReview] = []
        
        guard
            let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String:Any],
            let listLatestReviews = json["aaData"] as? [[String]]
            else {
                return nil
        }
        
        let totalRecords = json["iTotalRecords"] as? Int
        
        listLatestReviews.forEach { (reviewDetail) in
            guard reviewDetail.count == 7 else {
                assertionFailure("Unexpected data format.")
                return
            }
            
            let updatedDate = reviewDetail[0]
            
            var reviewURLString: String?
            if let reviewURLSubString = reviewDetail[1].subString(after: "href=\"", before: "\" title", options: .caseInsensitive) {
                reviewURLString = String(reviewURLSubString)
            }
 
            var band: BandLite?
            if let bandNameSubString = reviewDetail[2].subString(after: "\">", before: "</a>", options: .caseInsensitive),
                let bandURLSubString = reviewDetail[2].subString(after: "href=\"", before: "\">", options: .caseInsensitive) {
                band = BandLite(name: String(bandNameSubString), urlString: String(bandURLSubString))
            }
            
            var release: ReleaseExtraLite?
            if let releaseNameSubString = reviewDetail[3].subString(after: "\">", before: "</a>", options: .caseInsensitive),
                let releaseURLSubString = reviewDetail[3].subString(after: "href=\"", before: "\">", options: .caseInsensitive) {
                release = ReleaseExtraLite(urlString: String(releaseURLSubString), name: String(releaseNameSubString))
            }

            let rating = Int(reviewDetail[4].replacingOccurrences(of: "%", with: ""))
            
            var author: String?
            if let authorSubString = reviewDetail[5].subString(after: "\">", before: "</a>", options: .caseInsensitive) {
                author = String(authorSubString)
            }
            let timeString = reviewDetail[6]
            
            
            if let `reviewURLString` = reviewURLString, let `band` = band, let `release` = release, let `rating` = rating, let `author` = author {
                if let latestReview = LatestReview(dateString: updatedDate, reviewURLString: reviewURLString, band: band, release: release, rating: rating, timeString: timeString, author: author) {
                    list.append(latestReview)
                }
            }
            
        }
        
        if list.count == 0 {
            return (nil, nil)
        }
        return (list, totalRecords)
    }
}

//MARK: - Actionable
extension LatestReview: Actionable {
    var actionableElements: [ActionableElement] {
        let bandElement = ActionableElement(name: self.band.name, urlString: self.band.urlString, type: .band)
        let releaseElement = ActionableElement(name: self.release.name, urlString: self.release.urlString, type: .release)
        let reviewElement = ActionableElement(name: "By \(self.author) - \(self.rating)%", urlString: self.reviewURLString, type: .review)
        return [bandElement, releaseElement, reviewElement]
    }
}
