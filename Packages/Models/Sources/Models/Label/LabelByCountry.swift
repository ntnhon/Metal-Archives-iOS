//
//  LabelByCountry.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 23/10/2022.
//

import Foundation

public struct LabelByCountry: Sendable, Hashable {
    public let label: LabelLite
    public let specialisation: String?
    public let status: LabelStatus
    public let website: String?
    public let onlineShopping: Bool

    public init(label: LabelLite,
                specialisation: String?,
                status: LabelStatus,
                website: String?,
                onlineShopping: Bool)
    {
        self.label = label
        self.specialisation = specialisation
        self.status = status
        self.website = website
        self.onlineShopping = onlineShopping
    }
}
