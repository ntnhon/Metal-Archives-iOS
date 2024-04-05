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
        case "active":
            self = .active
        case "on hold":
            self = .onHold
        case "split-up", "split up":
            self = .splitUp
        case "changed name":
            self = .changedName
        case "disputed":
            self = .disputed
        default:
            self = .unknown
        }
    }

    var color: Color {
        switch self {
        case .active:
            .green
        case .onHold:
            .yellow
        case .splitUp:
            .red
        case .changedName:
            .blue
        case .unknown:
            .orange
        case .disputed:
            .purple
        }
    }

    var paramValue: Int {
        switch self {
        case .active:
            1
        case .onHold:
            2
        case .splitUp:
            3
        case .changedName:
            5
        case .unknown:
            4
        case .disputed:
            6
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
