//
//  BandStatus.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 25/05/2021.
//

import Combine
import SwiftUI

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

    var color: Color {
        switch self {
        case .active: return .green
        case .onHold: return .yellow
        case .splitUp: return .red
        case .changedName: return .blue
        case .unknown: return .orange
        case .disputed: return .purple
        }
    }

    var paramValue: Int {
        switch self {
        case .active: return 1
        case .onHold: return 2
        case .splitUp: return 3
        case .changedName: return 5
        case .unknown: return 4
        case .disputed: return 6
        }
    }
}

extension BandStatus: Identifiable {
    var id: String { rawValue }
}

extension BandStatus: MultipleChoiceProtocol {
    static var noChoice: String { "Any status" }
    static var multipleChoicesSuffix: String { "statuses selected" }
    static var totalChoices: Int { BandStatus.allCases.count }
    var choiceDescription: String { rawValue }
}

final class BandStatusSet: MultipleChoiceSet<BandStatus>, ObservableObject {}
