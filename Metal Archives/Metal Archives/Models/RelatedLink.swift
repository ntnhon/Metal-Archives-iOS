//
//  RelatedLink.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

import Foundation
import Kanna

struct RelatedLink {
    let urlString: String
    let favIconUrlString: String?
    let title: String

    init(urlString: String, title: String) {
        self.urlString = urlString
        self.title = title
        if let components = URLComponents(string: urlString),
           let scheme = components.scheme,
           let host = components.host {
            self.favIconUrlString = "http://www.google.com/s2/favicons?domain=\(scheme)://\(host)"
        } else {
            self.favIconUrlString = nil
        }
    }
}

extension Array where Element == RelatedLink {
    init(data: Data) {
        guard let htmlString = String(data: data, encoding: String.Encoding.utf8),
              !htmlString.contains("No links have been added yet"),
              let html = try? Kanna.HTML(html: htmlString, encoding: String.Encoding.utf8) else {
            self = []
            return
        }

        var links = [RelatedLink]()
        // swiftlint:disable:next identifier_name
        html.css("a").forEach { a in
            if let title = a.text, let urlString = a["href"], urlString.contains("http") {
                // Make sure that urlString contain "http" because it can have
                // other values like "#" or "#band_links_Official"
                links.append(.init(urlString: urlString, title: title))
            }
        }
        self = links
    }
}
