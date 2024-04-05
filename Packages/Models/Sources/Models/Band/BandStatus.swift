//
//  BandStatus.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 25/05/2021.
//

import Foundation

public enum BandStatus: String, Sendable, CaseIterable {
    case active = "Active"
    case onHold = "On hold"
    case splitUp = "Split up"
    case changedName = "Changed name"
    case unknown = "Unknown"
    case disputed = "Disputed"
}

extension BandStatus: Identifiable {
    public var id: String { rawValue }
}
