//
//  ArtistStatistic.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

struct ArtistStatistic {
    let total: Int
    let stillPlaying: Int
    let quitPlaying: Int
    let deceased: Int
    let female: Int
    let male: Int
    let nonBinary: Int
    let nonGendered: Int
    let unknown: Int

    init(_ text: String) {
        /*
         <p>
         There is a total of <strong>766243</strong> artists. 630336 are still playing. 135907 quit playing music / metal. 6109 are deceased. 52901 are female, 705493 are male, 69 are non-binary, 515 are non-gendered entities (companies, orchestras, etc.), and 7232 are unknown.
         </p>
         */
        let matches = RegexHelpers.listMatches(for: #"\d+"#, inString: text)
        let numberAtIndex: (Int) -> Int = { index in
            matches.indices.contains(index ) ? Int(matches[index]) ?? 0 : 0
        }
        total = numberAtIndex(0)
        stillPlaying = numberAtIndex(1)
        quitPlaying = numberAtIndex(2)
        deceased = numberAtIndex(3)
        female = numberAtIndex(4)
        male = numberAtIndex(5)
        nonBinary = numberAtIndex(6)
        nonGendered = numberAtIndex(7)
        unknown = numberAtIndex(8)
    }
}
