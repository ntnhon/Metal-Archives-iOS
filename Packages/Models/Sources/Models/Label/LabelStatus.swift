//
//  LabelStatus.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 22/10/2022.
//

import Foundation

public enum LabelStatus: String, Sendable {
    case active = "Active"
    case closed = "Closed"
    case unknown = "Unknown"
    case changedName = "Changed name"
    case onHold = "On hold"
}
