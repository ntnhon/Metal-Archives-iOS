//
//  MembersType.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 16/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

enum MembersType: Int, CustomStringConvertible, CaseIterable {
    case complete = 0, current, lastKnown, past, live
    
    var description: String {
        switch self {
        case .complete: return "Complete"
        case .current: return "Current"
        case .lastKnown: return "Last Known"
        case .past: return "Past"
        case .live: return "Live"
        }
        
    }
}
