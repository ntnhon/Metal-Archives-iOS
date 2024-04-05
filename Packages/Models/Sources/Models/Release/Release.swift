//
//  Release.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

import Foundation

public struct Release: Sendable {
    public let id: String
    public let urlString: String
    public let bands: [BandLite]
    public let coverUrlString: String?
    public let title: String
    public let type: ReleaseType
    public let date: String
    public let catalogId: String
    public let label: LabelLite
    public let format: String
    public let additionalHtmlNote: String?
    public let reviewCount: Int?
    public let rating: Int?
    public let otherInfo: [String] // optional info like: version desc, authenticity, limitation...
    public let modificationInfo: ModificationInfo
    public var isBookmarked: Bool
    public let elements: [ReleaseElement]
    public let bandMembers: [BandInRelease]
    public let guestMembers: [BandInRelease]
    public let otherStaff: [BandInRelease]
    public let reviews: [ReviewLite]

    public init(id: String,
                urlString: String,
                bands: [BandLite],
                coverUrlString: String?,
                title: String,
                type: ReleaseType,
                date: String,
                catalogId: String,
                label: LabelLite,
                format: String,
                additionalHtmlNote: String?,
                reviewCount: Int?,
                rating: Int?,
                otherInfo: [String],
                modificationInfo: ModificationInfo,
                isBookmarked: Bool,
                elements: [ReleaseElement],
                bandMembers: [BandInRelease],
                guestMembers: [BandInRelease],
                otherStaff: [BandInRelease],
                reviews: [ReviewLite])
    {
        self.id = id
        self.urlString = urlString
        self.bands = bands
        self.coverUrlString = coverUrlString
        self.title = title
        self.type = type
        self.date = date
        self.catalogId = catalogId
        self.label = label
        self.format = format
        self.additionalHtmlNote = additionalHtmlNote
        self.reviewCount = reviewCount
        self.rating = rating
        self.otherInfo = otherInfo
        self.modificationInfo = modificationInfo
        self.isBookmarked = isBookmarked
        self.elements = elements
        self.bandMembers = bandMembers
        self.guestMembers = guestMembers
        self.otherStaff = otherStaff
        self.reviews = reviews
    }
}
