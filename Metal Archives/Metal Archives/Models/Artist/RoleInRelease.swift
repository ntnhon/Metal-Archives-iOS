//
//  RoleInRelease.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 29/05/2021.
//

import Foundation

struct RoleInRelease {
    let year: String
    let release: ReleaseLite
    let releaseAdditionalInfo: String?
    let description: String
}

extension RoleInRelease {
    final class Builder {
        var year: String?
        var release: ReleaseLite?
        var releaseAdditionalInfo: String?
        var description: String?

        func build() -> RoleInRelease? {
            guard let year else {
                Logger.log("[Building RoleInRelease] year can not be nil.")
                return nil
            }

            guard let release else {
                Logger.log("[Building RoleInRelease] release can not be nil.")
                return nil
            }

            guard let description else {
                Logger.log("[Building RoleInRelease] description can not be nil.")
                return nil
            }

            return RoleInRelease(year: year,
                                 release: release,
                                 releaseAdditionalInfo: releaseAdditionalInfo,
                                 description: description)
        }
    }
}
