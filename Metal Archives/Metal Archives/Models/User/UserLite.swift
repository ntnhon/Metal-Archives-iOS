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
}

extension UserLite: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(urlString)
    }
}
