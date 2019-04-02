//
//  LineUpType.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 16/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

enum LineUpType: CustomStringConvertible {
    case complete, member, guest, other
    
    var description: String {
        switch self {
        case .complete: return "Complete"
        case .member: return "Band Members"
        case .guest: return "Guest/Session"
        case .other: return "Other Staff"
        }
    }
}
