//
//  DiscographyMode.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 20/06/2021.
//

import Foundation

public enum DiscographyMode: Int, Sendable, CustomStringConvertible, CaseIterable {
    case complete = 0, main, lives, demos, misc

    public var description: String {
        switch self {
        case .complete:
            "Complete"
        case .main:
            "Main"
        case .lives:
            "Lives"
        case .demos:
            "Demos"
        case .misc:
            "Misc."
        }
    }
}
