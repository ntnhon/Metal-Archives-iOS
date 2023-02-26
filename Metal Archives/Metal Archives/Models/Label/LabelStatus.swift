//
//  LabelStatus.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 22/10/2022.
//

import SwiftUI

enum LabelStatus: String {
    case active = "Active"
    case closed = "Closed"
    case unknown = "Unknown"
    case changedName = "Changed name"
    case onHold = "On hold"

    init(rawValue: String) {
        switch rawValue.lowercased() {
        case "active": self = .active
        case "closed": self = .closed
        case "unknown": self = .unknown
        case "changed name": self = .changedName
        case "on hold": self = .onHold
        default: self = .unknown
        }
    }

    var color: Color {
        switch self {
        case .active: return .green
        case .closed: return .red
        case .unknown: return .orange
        case .changedName: return .blue
        case .onHold: return .yellow
        }
    }
}
