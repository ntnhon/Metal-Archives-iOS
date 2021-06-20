//
//  DiscographyMode.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 20/06/2021.
//

import Foundation

// swiftlint:disable explicit_enum_raw_value
enum DiscographyMode: Int, CustomStringConvertible {
    case complete = 0, main, lives, demos, misc

    var description: String {
        switch self {
        case .complete: return "Complete"
        case .main: return "Main"
        case .lives: return "Lives"
        case .demos: return "Demos"
        case .misc: return "Misc."
        }
    }
}
