//
//  LatestReview.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 15/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class LatestReview {
    let title: String
    let reviewURLString: String
    let band: BandLite
    let release: ReleaseExtraLite
    let rating: Int
    let dateString: String
    let timeString: String
    let author: UserLite
    
    lazy var authorAndRatingAndDateAttributedString: NSAttributedString = {
        let authorAndRatingAndDateString = "\(author.name) • \(rating)% • \(dateString), \(timeString)"
        let mutableAttributedString = NSMutableAttributedString(string: authorAndRatingAndDateString)
        
        mutableAttributedString.addAttributes([.foregroundColor: Settings.currentTheme.bodyTextColor, .font: Settings.currentFontSize.bodyTextFont], range: NSRange(authorAndRatingAndDateString.startIndex..., in: authorAndRatingAndDateString))
        
        if let authorNameRange = authorAndRatingAndDateString.range(of: author.name) {
            mutableAttributedString.addAttributes([.foregroundColor: Settings.currentTheme.secondaryTitleColor, .font: Settings.currentFontSize.italicBodyTextFont], range: NSRange(authorNameRange, in: authorAndRatingAndDateString))
        }

        if let ratingRange = authorAndRatingAndDateString.range(of: "\(rating)%") {
            mutableAttributedString.addAttributes([.foregroundColor: UIColor.colorByRating(rating), .font: Settings.currentFontSize.boldBodyTextFont], range: NSRange(ratingRange, in: authorAndRatingAndDateString))
        }
        
        return mutableAttributedString
    }()
    
    /*
     Sample array:
     "May 2",
     "<a href="https://www.metal-archives.com/reviews/Meshuggah/Destroy_Erase_Improve/53/eletrikk/472675" title="Only If They Kept This Sound" class="iconContainer ui-state-default ui-corner-all"><span class="ui-icon ui-icon-search">Read</span></a>",
     "<a href="https://www.metal-archives.com/bands/Meshuggah/21">Meshuggah</a>",
     "<a href="https://www.metal-archives.com/albums/Meshuggah/Destroy_Erase_Improve/53">Destroy Erase Improve</a>",
     "88%",
     "<a href="https://www.metal-archives.com/users/eletrikk" class="profileMenu">eletrikk</a>",
     "07:29"
     */
    
    init?(from array: [String]) {
        guard array.count == 7 else { return nil }
        
        guard
            let reviewURLSubstring = array[1].subString(after: #"href=""#, before: #"" "#, options: .caseInsensitive),
            let titleSubstring = array[1].subString(after: #"title=""#, before: #"" "#, options: .caseInsensitive) else {
                return nil
        }
        
        guard
            let band = BandLite(from: array[2]),
            let release = ReleaseExtraLite(from: array[3]),
            let author = UserLite(from: array[5]) else {
            return nil
        }
        
        guard let rating = Int(array[4].replacingOccurrences(of: "%", with: "")) else {
            return nil
        }
        
        self.title = String(titleSubstring)
        self.reviewURLString = String(reviewURLSubstring)
        self.band = band
        self.release = release
        self.rating = rating
        self.dateString = array[0]
        self.timeString = array[6]
        self.author = author
    }
}

//MARK: - Pagable
extension LatestReview: Pagable {
    static var rawRequestURLString = "https://www.metal-archives.com/review/ajax-list-browse/by/date/selection/<YEAR_MONTH>?sEcho=3&iColumns=7&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=200&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&mDataProp_4=4&mDataProp_5=5&mDataProp_6=6&iSortCol_0=6&sSortDir_0=desc&iSortingCols=1&bSortable_0=true&bSortable_1=false&bSortable_2=true&bSortable_3=false&bSortable_4=true&bSortable_5=true&bSortable_6=true&_=1550957396237"
    static var displayLength = 200
    
    static func parseListFrom(data: Data) -> (objects: [LatestReview]?, totalRecords: Int?)? {
        guard let (totalRecords, array) = parseTotalRecordsAndArrayOfRawValues(data) else {
            return nil
        }
        var list: [LatestReview] = []
        
        array.forEach { (latestReviewDetails) in
            if let latestReview = LatestReview(from: latestReviewDetails) {
                list.append(latestReview)
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
        let bandElement = ActionableElement.band(name: band.name, urlString: band.urlString)
        let releaseElement = ActionableElement.release(name: release.title, urlString: release.urlString)
        let userElement = ActionableElement.user(name: author.name, urlString: author.urlString)
        let reviewElement = ActionableElement.review(name: "By \(self.author.name) - \(self.rating)%", urlString: reviewURLString)
        return [bandElement, releaseElement, reviewElement, userElement]
    }
}
