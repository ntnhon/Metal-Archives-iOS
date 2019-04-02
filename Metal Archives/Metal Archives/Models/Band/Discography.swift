//
//  Discography.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 30/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import Kanna

final class Discography {
    private var releases: [ReleaseLite]? = nil
    
    lazy var complete: [ReleaseLite] = {
        if let `releases` = self.releases {
            return releases
        }
        return []
    }()
    
    lazy var main: [ReleaseLite] = {
        if let `releases` = self.releases {
           return releases.filter {
            $0.type == ReleaseType.fullLength
            }
        }
        
        return []
    }()
    
    lazy var lives: [ReleaseLite] = {
        if let `releases` = self.releases {
            return releases.filter {
                $0.type == ReleaseType.liveAlbum || $0.type == ReleaseType.video
            }
        }
        
        return []
    }()
    
    lazy var demos: [ReleaseLite] = {
        if let `releases` = self.releases {
            return releases.filter {
                $0.type == ReleaseType.demo
            }
        }
        
        return []
    }()
    
    lazy var misc: [ReleaseLite] = {
        if let `releases` = self.releases {
            return releases.filter {
                $0.type != ReleaseType.demo && $0.type != ReleaseType.fullLength && $0.type != ReleaseType.liveAlbum && $0.type != ReleaseType.video
            }
        }
        
        return []
    }()
    
    init?(data: Data) {
        guard let htmlString = String(data: data, encoding: String.Encoding.utf8),
            let html = try? Kanna.HTML(html: htmlString, encoding: String.Encoding.utf8) else {
                return nil
        }
        
        self.releases = [ReleaseLite]()
        
        for tbody in html.css("tbody") {
            for tr in tbody.css("tr") {
                
                var title: String?
                var urlString: String?
                var type: ReleaseType?
                var year: Int?
                var numberOfReviews: Int?
                var averagePoint: Int?
                var reviewsURLString: String?
                var i = 0
                
                //This band has no release yet
                if tr.css("td").count == 1 && tr.innerHTML!.contains("Nothing entered yet") {
                    return nil
                }
                
                for td in tr.css("td") {
                    if (i == 0) {
                        // Get disc name and disc URL
                        title = td.text
                        urlString = td.css("a")[0]["href"]
                    }
                    else if (i == 1) {
                        // Get disc type
                        if let releaseTypeString = td.text {
                            type = ReleaseType(typeString: releaseTypeString)
                        }
                    }
                    else if (i == 2) {
                        // Get disc year
                        if let yearString = td.text {
                            year = Int(yearString)
                        }
                        
                    }
                    else if (i == 3) {
                        // Get disc's reviews
                        if var reviewString = td.text {
                            reviewString = reviewString.replacingOccurrences(of: "\t", with: "")
                            reviewString = reviewString.replacingOccurrences(of: "\n", with: "")
                            reviewString = reviewString.replacingOccurrences(of: " ", with: "")
                            reviewString = reviewString.replacingOccurrences(of: "(", with: " (")
                            
                            if let numberOfReviewsString = reviewString.components(separatedBy: " ").first {
                                numberOfReviews = Int(numberOfReviewsString)
                            }
                            
                            if let averagePointString = reviewString.subString(after: "(", before: "%)", options: .caseInsensitive) {
                                averagePoint = Int(averagePointString)
                            }
                            
                            for a in td.css("a") {
                                if var reviewURLString = a["href"] {
                                    reviewURLString = reviewURLString.replacingOccurrences(of: "\t", with: "")
                                    reviewURLString = reviewURLString.replacingOccurrences(of: "\n", with: "")
                                    reviewURLString = reviewURLString.replacingOccurrences(of: " ", with: "")
                                    reviewsURLString = reviewURLString
                                }
                            }
                        }
                        
                    }
                    
                    i = i + 1
                }
                
                if let `title` = title, let `urlString` = urlString, let `type` = type, let `year` = year {
                    if let release = ReleaseLite(urlString: urlString, type: type, title: title, year: year, numberOfReviews: numberOfReviews, averagePoint: averagePoint, reviewsURLString: reviewsURLString) {
                        self.releases?.append(release)
                    }
                    
                } else {
                    #warning("Handle error")
                }

            }
        }
    }
}
