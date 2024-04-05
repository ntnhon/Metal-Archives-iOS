//
//  LabelSimpleSearchResult.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 16/11/2022.
//

import Foundation

public struct LabelSimpleSearchResult: Sendable, Hashable {
    public let label: LabelLite
    public let note: String?
    public let country: Country
    public let specialisation: String

    public init(label: LabelLite,
                note: String?,
                country: Country,
                specialisation: String)
    {
        self.label = label
        self.note = note
        self.country = country
        self.specialisation = specialisation
    }
}
