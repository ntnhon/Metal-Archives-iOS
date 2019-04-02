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
    private(set) var bandName: String!
    private(set) var bandURLString: String!
    private(set) var releaseTitle: String!
    private(set) var releaseURLString: String!
    private(set) var coverPhotoURLString: String?
    private(set) var title: String!
    private(set) var rating: Int!
    private(set) var authorName: String!
    private(set) var dateAndReleaseVersionHTMLString: String!
    private(set) var htmlContentString: String!
    
    init?(data: Data) {
        guard let htmlString = String(data: data, encoding: String.Encoding.utf8),
            let doc = try? Kanna.HTML(html: htmlString, encoding: String.Encoding.utf8) else {
                return nil
        }
        
        for div in doc.css("div") {
            if (div["id"] == "album_content") {
                if let h1 = div.at_css("h1"), let a = h1.at_css("a") {
                    if let releaseURLString = a["href"], let releaseTitle = a.text {
                        self.releaseURLString = releaseURLString
                        self.releaseTitle = releaseTitle
                    }
                }
                
                if let h2 = div.at_css("h2"), let a = h2.at_css("a") {
                    if let bandURLString = a["href"], let bandName = a.text {
                        self.bandURLString = bandURLString
                        self.bandName = bandName
                    }
                }
            } else if (div["class"] == "album_img") {
                if let a = div.at_css("a"), let releaseCoverURLString = a["href"] {
                    self.coverPhotoURLString = releaseCoverURLString
                }
            } else if (div["class"] == "reviewBox") {
                if var titleAndRatingString = div.at_css("h3")?.text {
                    titleAndRatingString = titleAndRatingString.replacingOccurrences(of: "\n", with: "")
                    titleAndRatingString = titleAndRatingString.replacingOccurrences(of: "\t", with: "")
                    
                    if let lastIndexOfSeparator = titleAndRatingString.lastIndex(of: "-") {
                        var ratingString = String(titleAndRatingString[lastIndexOfSeparator...])
                        ratingString = ratingString.replacingOccurrences(of: "-", with: "")
                        ratingString = ratingString.replacingOccurrences(of: " ", with: "")
                        ratingString = ratingString.replacingOccurrences(of: "%", with: "")
                        self.rating = Int(ratingString)
                    } else {
                        return nil
                    }

                    if let `rating` = self.rating {
                        self.title = titleAndRatingString.replacingOccurrences(of: " - \(rating)% ", with: "")
                    }
                    
                }
                
                for subDiv in div.css("div") {
                    guard let a = subDiv.css("a").first, let aClassName = a.className, let authorName = a.text else {
                        continue
                    }
                    
                    if aClassName != "profileMenu" {
                        continue
                    }
                    
                    self.authorName = authorName
                    if var authorAndDateAndReleaseVersionString = subDiv.innerHTML {
                        //Remove Author name from string
                        authorAndDateAndReleaseVersionString = String(authorAndDateAndReleaseVersionString.subString(after: "</a>, ") ?? "")
                        
                        //Remove \n and \t
                        authorAndDateAndReleaseVersionString = authorAndDateAndReleaseVersionString.replacingOccurrences(of: "\n", with: "")
                        authorAndDateAndReleaseVersionString = authorAndDateAndReleaseVersionString.replacingOccurrences(of: "\t", with: "")
                        
                        self.dateAndReleaseVersionHTMLString = authorAndDateAndReleaseVersionString
                    }
                }
            } else if (div["class"] == "reviewContent") {
                self.htmlContentString = div.innerHTML
            }
        }
    }
}
