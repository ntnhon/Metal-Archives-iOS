//
//  Array+BandLite.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 15/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

extension Array where Element == BandLite {
    /*
     Sample string:
     "<a href="https://www.metal-archives.com/bands/Dark_Angel/126">Dark Angel</a> / <a href="https://www.metal-archives.com/bands/Death/141">Death</a> / <a href="https://www.metal-archives.com/bands/Forbidden/374">Forbidden</a> / <a href="https://www.metal-archives.com/bands/Faith_or_Fear/977">Faith or Fear</a> / <a href="https://www.metal-archives.com/bands/Raven/1129">Raven</a>"
     */
    static func fromString(_ string: String) -> [BandLite]? {
        var bands: [BandLite] = []
        
        let aTags = string.replacingOccurrences(of: " / ", with: "🤘").split(separator: "🤘")
        aTags.forEach { (substring) in
            if let band = BandLite.init(from: String(substring)) {
                bands.append(band)
            }
        }
        
        return bands.count > 0 ? bands : nil
    }
}
