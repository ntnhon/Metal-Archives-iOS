//
//  UserReview.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 14/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import AttributedLib

final class UserReview {
    let urlString: String
    let dateString: String
    let bands: [BandLite]
    let release: ReleaseExtraLite
    let title: String
    let rating: Int
    
    lazy var bandsAttributedString: NSAttributedString = {
        let bandNames = bands.map({$0.name})
        return generateAttributedStringFromStrings(bandNames, as: .title, withSeparator: " / ")
    }()
    
    lazy var ratingAndDateAttributedString: NSAttributedString = {
        let ratingAttributes = Attributes {
            return $0.foreground(color: UIColor.colorByRating(rating))
                .font(Settings.currentFontSize.bodyTextFont)
                .alignment(.justified)
        }
        return "\(rating)%".at.attributed(with: ratingAttributes) + " • \(dateString)".at.attributed(with: bodyTextAttributes)
    }()
    
    /*Sample array:
     "<a href='https://www.metal-archives.com/reviews/Wolfheart/Wolves_of_Karelia/827791/hells_unicorn/29518' class='iconContainer ui-state-default ui-corners-all' title='Read'><span class='ui-icon ui-icon-search'>Read</span></a>",
     "April 11th, 2020",
     "<a href="https://www.metal-archives.com/bands/Wolfheart/3540371106">Wolfheart</a>",
     "<a href="https://www.metal-archives.com/albums/Wolfheart/Wolves_of_Karelia/827791">Wolves of Karelia</a>",
     "Grand anthems for the lupine spirit in us all.",
     "88%"
     */
    
    init?(from array: [String]) {
        guard array.count == 6 else { return nil }
        
        guard let urlSubstring = array[0].subString(after: "href='", before: " class='", options: .caseInsensitive) else { return nil }
        
        guard let bands = Array<BandLite>.fromString(array[2]) else { return nil }
        
        guard let release = ReleaseExtraLite(from: array[3]) else { return nil }
        
        guard let rating = Int(array[5].replacingOccurrences(of: "%", with: "")) else { return nil }
        
        self.urlString = String(urlSubstring)
        self.dateString = array[1]
        self.bands = bands
        self.release = release
        self.title = array[4]
        self.rating = rating
    }
}

extension UserReview: Pagable {
    static var rawRequestURLString = "https://www.metal-archives.com/review/ajax-list-user/userId/<USER_ID>?sEcho=1&iColumns=6&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=<DISPLAY_LENGTH>&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&mDataProp_4=4&mDataProp_5=5&iSortCol_0=<SORT_COLUMN>&sSortDir_0=<SORT_ORDER>&iSortingCols=1&bSortable_0=false&bSortable_1=true&bSortable_2=true&bSortable_3=true&bSortable_4=true&bSortable_5=true&_=1586884148723"
    
    static var displayLenght = 200
    
    static func parseListFrom(data: Data) -> (objects: [UserReview]?, totalRecords: Int?)? {
        guard let (totalRecords, array) = parseTotalRecordsAndArrayOfRawValues(data) else {
            return nil
        }
        var list: [UserReview] = []
        
        array.forEach { (userReviewDetails) in
            if let userReview = UserReview(from: userReviewDetails) {
                list.append(userReview)
            }
        }
        
        if list.count == 0 {
            return (nil, nil)
        }
        return (list, totalRecords)
    }
}

// MARK: - Actionable
extension UserReview: Actionable {
    var actionableElements: [ActionableElement] {
        var elements: [ActionableElement] = []
        
        let reviewElement = ActionableElement.review(name: title, urlString: urlString)
        elements.append(reviewElement)
        
        let releaseElement = ActionableElement.release(name: release.title, urlString: release.urlString)
        elements.append(releaseElement)
        
        self.bands.forEach { (eachBand) in
            let bandElement = ActionableElement.band(name: eachBand.name, urlString: eachBand.urlString)
            elements.append(bandElement)
        }
        
        return elements
    }
}
