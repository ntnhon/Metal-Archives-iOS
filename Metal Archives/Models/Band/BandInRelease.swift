//
//  BandInRelease.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 26/05/2021.
//

import Foundation

// In case of Split or Original line up
// members are separated by bands
struct BandInRelease {
    let name: String?
    let members: [ArtistInRelease]
}

extension BandInRelease: Hashable {
    func hash(into hasher: inout Hasher) {
        if let name {
            hasher.combine(name)
        }
        hasher.combine(members)
    }
}
