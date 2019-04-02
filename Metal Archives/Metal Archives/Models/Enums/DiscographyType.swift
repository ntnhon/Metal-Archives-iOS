//
//  DiscographyType.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 16/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

enum DiscographyType: Int, CustomStringConvertible, CaseIterable {
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
