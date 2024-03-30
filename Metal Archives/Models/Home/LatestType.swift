//
//  LatestType.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 24/12/2022.
//

import Foundation

enum LatestType {
    case added, updated

    var path: String {
        switch self {
        case .added:
            return "created"
        case .updated:
            return "modified"
        }
    }
}
