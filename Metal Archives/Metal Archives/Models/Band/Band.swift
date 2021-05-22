//
//  Band.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

struct Band {
    
}

// MARK: - Status
extension Band {
    enum Status: String {
        case active = "Active"
        case onHold = "On hold"
        case splitUp = "Split up"
        case changedName = "Changed name"
        case unknown = "Unknown"
        case disputed = "Disputed"

        init(rawValue: String) {
            switch rawValue.lowercased() {
            case "active": self = .active
            case "on hold": self = .onHold
            case "split-up", "split up": self = .splitUp
            case "changed name": self = .changedName
            case "disputed": self = .disputed
            default: self = .unknown
            }
        }
    }
}

// MARK: - Old Identity
extension Band {
    struct OldIdentity {
        let name: String
        let urlString: String
    }
}
