//
//  BandStatus.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 25/05/2021.
//

import Combine

enum BandStatus: String, CaseIterable {
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

final class BandStatusSet: ObservableObject {
    @Published var status: [BandStatus] = []

    var detailString: String {
        if status.isEmpty {
            return "Any status"
        } else {
            return status.map { $0.rawValue }.joined(separator: ", ")
        }
    }
}
