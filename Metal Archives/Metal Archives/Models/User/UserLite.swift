//
//  UserLite.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

import Foundation

struct UserLite {
    let name: String
    let urlString: String

    // Example:
    // "<a href="https://www.metal-archives.com/users/Euthanasiast" class="profileMenu">Euthanasiast</a>"
    init?(from string: String) {
        guard let urlString = string.subString(after: #"href=""#, before: #"" "#, options: .caseInsensitive),
              let name = string.subString(after: #"">"#, before: "</a>", options: .caseInsensitive) else {
            return nil
        }
        self.name = name
        self.urlString = urlString
    }
}
