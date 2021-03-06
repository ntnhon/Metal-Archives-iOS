//
//  ReviewLite.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 03/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

final class ReviewLite: Pagable {
    let urlString: String
    let releaseTitle: String
    let rating: Int
    let dateString: String
    let user: UserLite
    
    lazy var ratingAndUsernameAttributedString: NSAttributedString? = {
        guard let release = release else {
            return nil
        }
        
        let detailString = "\(rating)% • \(release.type.description) • \(user.name)"
        let attributedString = NSMutableAttributedString(string: detailString)
        attributedString.addAttributes([.foregroundColor: Settings.currentTheme.bodyTextColor, .font: Settings.currentFontSize.bodyTextFont], range: NSRange(detailString.startIndex..., in: detailString))
        
        if let rangeOfUserName = detailString.range(of: "\(user.name)") {
            attributedString.addAttributes([.foregroundColor: Settings.currentTheme.secondaryTitleColor], range: NSRange(rangeOfUserName, in: detailString))
        }
        
        if let rangeOfType = detailString.range(of: "\(release.type.description)") {
            let font: UIFont
            switch release.type {
            case .fullLength: font = Settings.currentFontSize.heavyBodyTextFont
            case .demo: font = Settings.currentFontSize.italicBodyTextFont
            case .single: font = Settings.currentFontSize.tertiaryFont
            default: font = Settings.currentFontSize.bodyTextFont
            }
            
            attributedString.addAttribute(.font, value: font, range: NSRange(rangeOfType, in: detailString))
        }
        
        if let rangeOfRating = detailString.range(of: "\(rating)%") {
            attributedString.addAttributes([.foregroundColor: UIColor.colorByRating(rating)], range: NSRange(rangeOfRating, in: detailString))
        }
        
        return attributedString
    }()
    
    //Iterate releases in bands in order to find a corresponding ReleaseLite
    // => set thumbnail to review cell
    private(set) var release: ReleaseLite?

    func associateToRelease(_ release: ReleaseLite) {
        self.release = release
    }
    
    static var rawRequestURLString = "https://www.metal-archives.com/review/ajax-list-band/id/<BAND_ID>/json/1?sEcho=1&iColumns=4&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=<DISPLAY_LENGTH>&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&iSortCol_0=3&sSortDir_0=desc&iSortingCols=1&bSortable_0=true&bSortable_1=true&bSortable_2=true&bSortable_3=true"
    
    static var displayLength = 200
    
    /*
     Sample array:
     "<a href='https://www.metal-archives.com/reviews/Death/Human/606/mordor_machine/565946'>Human</a>",
     "100%",
     "<a href="https://www.metal-archives.com/users/mordor_machine" class="profileMenu">mordor_machine</a>",
     "May 22nd, 2019"
     */
    
    init?(from array: [String]) {
        guard array.count == 4 else { return nil }
        
        guard let releaseTitleSubstring = array[0].subString(after: #"'>"#, before: "</a>", options: .caseInsensitive),
            let urlSubstring = array[0].subString(after: #"href='"#, before: #"'>"#, options: .caseInsensitive) else { return nil }
        
        let ratingString = array[1].replacingOccurrences(of: "%", with: "")
        let user = UserLite(from: array[2])
        let dateString = array[3]
        
        if let rating = Int(ratingString), let user = user {
            self.urlString = String(urlSubstring)
            self.releaseTitle = String(releaseTitleSubstring)
            self.rating = rating
            self.dateString = dateString
            self.user = user
        } else {
            return nil
        }
    }
}

// MARK: - Actionable
extension ReviewLite: Actionable {
    var actionableElements: [ActionableElement] {
        var elements = [ActionableElement]()
        if let release = release {
            let releaseElement = ActionableElement.release(name: release.title, urlString: release.urlString)
            elements.append(releaseElement)
        }

        let reviewElement = ActionableElement.review(name: "By \(user.name) - \(rating)%", urlString: urlString)
        elements.append(reviewElement)
        
        let userElement = ActionableElement.user(name: user.name, urlString: user.urlString)
        elements.append(userElement)
        
        return elements
    }
}
