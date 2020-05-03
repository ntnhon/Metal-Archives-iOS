//
//  News.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 15/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import Kanna
import AttributedLib

final class News {
    let title: String
    let date: Date
    let htmlBody: String
    let author: String
    let urlString: String
    
    lazy var summaryAttributedText: NSAttributedString = {
        let attrString = NSMutableAttributedString()
        
        attrString.append("\(title)\n".at.attributed(with: titleAttributes))
        attrString.append("By ".at.attributed(with: bodyTextAttributes))
        attrString.append(author.at.attributed(with: secondaryTitleAttributes))
        attrString.append(" on ".at.attributed(with: bodyTextAttributes))
        attrString.append("\(dateString)\n".at.attributed(with: boldBodyTextAttributes))
        attrString.append(htmlBody.at.attributed(with: bodyTextAttributes))
        
        return attrString
    }()
    
    lazy var dateString: String = {
       return dateOnlyFormatter.string(from: self.date)
    }()
    
    lazy var dateAndTimeString: String = {
        return defaultDateFormatter.string(from: self.date)
    }()
    
    init(title: String, date: Date, htmlBody: String, author: String, urlString: String) {
        self.title = title
        self.date = date
        self.htmlBody = htmlBody
        self.author = author
        self.urlString = urlString
    }
}

extension News: Pagable {
    static var rawRequestURLString: String = "https://www.metal-archives.com/news/index/p/"
    static var displayLength = Int.min
    
    static func requestURLString(forPage page: Int, withOptions options: [String : String]?) -> String {
        return rawRequestURLString + "\(page)"
    }
    
    convenience init?(from array: [String]) {
        return nil
    }
    
    static func parseListFrom(data: Data) -> (objects: [News]?, totalRecords: Int?)? {
        guard
            let htmlString = String(data: data, encoding: String.Encoding.utf8),
            let doc = try? Kanna.HTML(html: htmlString, encoding: String.Encoding.utf8)
        else {
            return nil
        }
        
        var list: [News] = []
        for div in doc.css("div") {
            if(div["class"] == "motd") {
                
                var title: String?
                var date: Date?
                var htmlBody: String?
                var author: String?
                var urlString: String?
                
                for a in div.css("a") {
                    if (a["class"] == "iconContainer ui-state-default ui-corner-all") {
                        urlString = a["href"]
                    }
                }
                
                for span in div.css("span") {
                    if (span["class"] == "title") {
                        title = span.text
                    } else if (span["class"] == "date"), let dateString = span.text {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                        date = dateFormatter.date(from: dateString)
                    }
                }
                
                for p in div.css("p") {
                    if (p["class"] == "body") {
                        htmlBody = p.innerHTML?.replacingOccurrences(of: "<[^>]+>", with: "", options: String.CompareOptions.regularExpression, range: nil)
                        
                        //Work around: remove "\n\t\t"
                        // at the beginning and the end of each news
                        htmlBody?.removeEmptySpaces()
                    }
                    
                    if (p["class"] == "signature") {
                        if let a = p.at_css("a") {
                            author = a.text
                        }
                    }
                }
                
                if let `title` = title, let `date` = date, let `htmlBody` = htmlBody, let `author` = author, let `urlString` = urlString {
                    let news = News.init(title: title, date: date, htmlBody: htmlBody, author: author, urlString: urlString)
                    list.append(news)
                }
            }
        }
        
        if list.count == 0 {
            return (nil, nil)
        }
        return (list, nil)
    }
}
