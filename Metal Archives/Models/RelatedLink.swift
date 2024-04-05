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
           let host = components.host
        {
            favIconUrlString = "https://www.google.com/s2/favicons?domain=\(scheme)://\(host)"
        } else {
            favIconUrlString = nil
        }
    }
}

struct RelatedLinkArray: HTMLParsable {
    let content: [RelatedLink]

    init(data: Data) {
        guard let htmlString = String(data: data, encoding: String.Encoding.utf8),
              !htmlString.contains("No links have been added yet"),
              let html = try? Kanna.HTML(html: htmlString, encoding: String.Encoding.utf8)
        else {
            content = []
            return
        }

        var links = [RelatedLink]()
        // swiftlint:disable:next identifier_name
        for a in html.css("a") {
            if let title = a.text, let urlString = a["href"], urlString.contains("http") {
                // Make sure that urlString contain "http" because it can have
                // other values like "#" or "#band_links_Official"
                links.append(.init(urlString: urlString, title: title))
            }
        }
        content = links
    }
}
