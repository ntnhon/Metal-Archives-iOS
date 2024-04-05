//
//  LabelByAlphabet.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 22/10/2022.
//

import Foundation

public struct LabelByAlphabet: Sendable, Hashable {
    public let label: LabelLite
    public let country: Country?
    public let specialisation: String?
    public let status: LabelStatus
    public let website: String?
    public let onlineShopping: Bool

    public init(label: LabelLite,
                country: Country?,
                specialisation: String?,
                status: LabelStatus,
                website: String?,
                onlineShopping: Bool)
    {
        self.label = label
        self.country = country
        self.specialisation = specialisation
        self.status = status
        self.website = website
        self.onlineShopping = onlineShopping
    }
}
