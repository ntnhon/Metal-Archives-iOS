//
//  Review.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import Kanna

final class Review {
    private(set) var band: BandLite!
    private(set) var release: ReleaseExtraLite!
    private(set) var coverPhotoURLString: String?
    private(set) var title: String!
    private(set) var rating: Int!
    private(set) var user: User!
    private(set) var dateString: String!
    private(set) var baseVersion: ReleaseExtraLite?
    private(set) var htmlContentString: String!
    
    deinit {
        print("Review is deallocated")
    }
    
    lazy var baseVersionAttributedString: NSAttributedString? = {
        guard let baseVersion = baseVersion else { return nil }
        
        let baseVersionString = "Written based on this version: \(baseVersion.title)"
        let mutableAttributedString = NSMutableAttributedString(string: baseVersionString)
        mutableAttributedString.addAttributes([.foregroundColor: Settings.currentTheme.bodyTextColor, .font: Settings.currentFontSize.bodyTextFont], range: NSRange(baseVersionString.startIndex..., in: baseVersionString))
        
        if let baseVersionRange = baseVersionString.range(of: baseVersion.title) {
            mutableAttributedString.addAttributes([.foregroundColor: Settings.currentTheme.secondaryTitleColor], range: NSRange(baseVersionRange, in: baseVersionString))
        }
        
        return mutableAttributedString
    }()
    
    init?(data: Data) {
        guard let htmlString = String(data: data, encoding: String.Encoding.utf8),
            let doc = try? Kanna.HTML(html: htmlString, encoding: String.Encoding.utf8) else {
                return nil
        }
        
        for div in doc.css("div") {
            if (div["id"] == "album_content") {
                if let h1 = div.at_css("h1"), let a = h1.at_css("a") {
                    if let releaseURLString = a["href"], let releaseTitle = a.text {
                        self.release = ReleaseExtraLite(urlString: releaseURLString, title: releaseTitle)
                    }
                }
                
                if let h2 = div.at_css("h2"), let a = h2.at_css("a") {
                    if let bandURLString = a["href"], let bandName = a.text {
                        self.band = BandLite(name: bandName, urlString: bandURLString)
                    }
                }
            } else if (div["class"] == "album_img") {
                if let a = div.at_css("a"), let releaseCoverURLString = a["href"] {
                    self.coverPhotoURLString = releaseCoverURLString
                }
            } else if (div["class"] == "reviewBox") {
                if let titleAndRatingString = div.at_css("h3")?.text?.removeHTMLTagsAndNoisySpaces() {
                    let numberStrings = RegexHelpers.listMatches(for: #"\d{1,3}(?<!%)"#, inString: titleAndRatingString)
                    if let lastNumberString = numberStrings.last, let rating = Int(lastNumberString) {
                        self.rating = rating
                        self.title = titleAndRatingString.replacingOccurrences(of: " - \(self.rating!)%", with: "")
                    }
                }
                
                // The 2nd div of the reviewBox div which contains:
                // user, date, base version (optional)
                let secondDiv = div.css("div")[1]
                
                // get the a tags
                let aTags = secondDiv.css("a")
                
                // 1st a tag contains user
                if let userName = aTags[0].text, let userURLString = aTags[0]["href"] {
                    self.user = User(name: userName, urlString: userURLString)
                }
                
                // 2nd a tag (optional) contains base version
                if aTags.count == 2 {
                    if let baseVersionURLString = aTags[1]["href"], let baseVersionTitle = aTags[1].text {
                        self.baseVersion = ReleaseExtraLite(urlString: baseVersionURLString, title: baseVersionTitle)
                    }
                }
                
                // get date
                if let secondDivText = secondDiv.text {
                    if let firstMatch = RegexHelpers.firstMatch(for: #"(January|February|March|April|May|June|July|August|September|October|November|December)\s\d{1,2}[a-z]{2},\s\d{4}"#, inString: secondDivText) {
                        self.dateString = firstMatch
                    }
                }

            } else if (div["class"] == "reviewContent") {
                self.htmlContentString = div.innerHTML
            }
        }
    }
}
