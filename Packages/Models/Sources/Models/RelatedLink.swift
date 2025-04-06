//
//  RelatedLink.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

import Foundation

public struct RelatedLink: Sendable, Hashable {
    public let urlString: String
    public let favIconUrlString: String?
    public let title: String

    public init(urlString: String, title: String) {
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
