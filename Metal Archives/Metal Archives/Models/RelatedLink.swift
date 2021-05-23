//
//  RelatedLink.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

import Foundation

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
