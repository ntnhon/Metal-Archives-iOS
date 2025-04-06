//
//  ModificationInfo.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

import Foundation

// Details page for bands, labels, releases, artists all holds an "auditTrail" tag
// which contains information about the auditor and timestamps
public struct ModificationInfo: Sendable {
    public let addedOnDate: Date?
    public let modifiedOnDate: Date?
    public let addedByUser: UserLite?
    public let modifiedByUser: UserLite?

    public init(addedOnDate: Date?,
                modifiedOnDate: Date?,
                addedByUser: UserLite?,
                modifiedByUser: UserLite?)
    {
        self.addedOnDate = addedOnDate
        self.modifiedOnDate = modifiedOnDate
        self.addedByUser = addedByUser
        self.modifiedByUser = modifiedByUser
    }
}
