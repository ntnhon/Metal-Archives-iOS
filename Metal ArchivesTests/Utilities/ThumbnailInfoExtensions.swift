//
//  ThumbnailInfoExtensions.swift
//  Metal ArchivesTests
//
//  Created by Thanh-Nhon Nguyen on 24/05/2021.
//

@testable import Metal_Archives

extension ThumbnailInfo {
    static func random(type: ThumbnailType?) -> ThumbnailInfo {
        // swiftlint:disable force_unwrapping
        ThumbnailInfo(urlString: "https://example.com/\(Int.randomId())",
                      type: type ?? ThumbnailType.allCases.randomElement()!)!
        // swiftlint:enable force_unwrapping
    }
}
