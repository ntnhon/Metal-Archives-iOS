//
//  LatestLabel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 23/12/2022.
//

import Foundation

public struct LatestLabel: Sendable, Hashable {
    public let date: String
    public let label: LabelLite
    public let status: LabelStatus
    public let country: Country
    public let dateAndTime: String
    public let author: UserLite

    public init(date: String,
                label: LabelLite,
                status: LabelStatus,
                country: Country,
                dateAndTime: String,
                author: UserLite)
    {
        self.date = date
        self.label = label
        self.status = status
        self.country = country
        self.dateAndTime = dateAndTime
        self.author = author
    }
}

extension LatestLabel: Identifiable {
    public var id: Int { hashValue }
}
