//
//  LabelDetail.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 03/11/2022.
//

import Foundation

public struct LabelDetail: Sendable {
    public let logoUrlString: String?
    public let name: String
    public let address: String
    public let country: Country
    public let phoneNumber: String
    public let status: LabelStatus
    public let specialties: String
    public let foundingDate: String
    public let parentLabel: LabelLite?
    public let subLabels: [LabelLite]
    public let onlineShopping: String
    public let isLastKnown: Bool
    public let website: RelatedLink?
    public let additionalNotes: String?
    public let modificationInfo: ModificationInfo

    public init(logoUrlString: String?,
                name: String,
                address: String,
                country: Country,
                phoneNumber: String,
                status: LabelStatus,
                specialties: String,
                foundingDate: String,
                parentLabel: LabelLite?,
                subLabels: [LabelLite],
                onlineShopping: String,
                isLastKnown: Bool,
                website: RelatedLink?,
                additionalNotes: String?,
                modificationInfo: ModificationInfo)
    {
        self.logoUrlString = logoUrlString
        self.name = name
        self.address = address
        self.country = country
        self.phoneNumber = phoneNumber
        self.status = status
        self.specialties = specialties
        self.foundingDate = foundingDate
        self.parentLabel = parentLabel
        self.subLabels = subLabels
        self.onlineShopping = onlineShopping
        self.isLastKnown = isLastKnown
        self.website = website
        self.additionalNotes = additionalNotes
        self.modificationInfo = modificationInfo
    }
}
