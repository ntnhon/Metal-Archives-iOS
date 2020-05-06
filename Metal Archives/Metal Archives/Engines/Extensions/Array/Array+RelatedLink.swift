//
//  Array+RelatedLink.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 06/05/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import Kanna

extension Array where Element == RelatedLink {
    static func from(data: Data) -> [RelatedLink]? {
        guard let htmlString = String(data: data, encoding: String.Encoding.utf8) else {
            return nil
        }
        
        var relatedLinks = [RelatedLink]()
        
        if let doc = try? Kanna.HTML(html: htmlString, encoding: String.Encoding.utf8) {
            for td in doc.css("td") {
                if let a = td.at_css("a") {
                    if let title = a.text, let urlString = a["href"] {
                        if let relatedLink = RelatedLink(title: title, urlString: urlString) {
                            relatedLinks.append(relatedLink)
                        }
                    }
                }
            }
        }
        
        if relatedLinks.count == 0 {
            return nil
        }

        return relatedLinks
    }
}
