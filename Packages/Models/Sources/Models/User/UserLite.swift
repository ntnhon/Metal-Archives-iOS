//
//  UserLite.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

import Foundation

public struct UserLite: Sendable, Hashable {
    public let name: String
    public let urlString: String

    public init(name: String, urlString: String) {
        self.name = name
        self.urlString = urlString
    }
}
