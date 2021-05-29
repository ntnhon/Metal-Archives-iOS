//
//  RoleInBand.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 29/05/2021.
//

import Foundation

struct RoleInBand {
    let band: BandExtraLite
    let description: String // Role and active year
    let roleInReleases: [RoleInRelease]
}

extension RoleInBand {
    final class Builder {
        var band: BandExtraLite?
        var description: String?
        var roleInReleases: [RoleInRelease]?

        func build() -> RoleInBand? {
            guard let band = band else {
                Logger.log("[Building RoleInBand] band can not be nil.")
                return nil
            }

            guard let description = description else {
                Logger.log("[Building RoleInBand] description can not be nil.")
                return nil
            }

            guard let roleInReleases = roleInReleases else {
                Logger.log("[Building RoleInBand] roleInReleases can not be nil.")
                return nil
            }

            return RoleInBand(band: band, description: description, roleInReleases: roleInReleases)
        }
    }
}
