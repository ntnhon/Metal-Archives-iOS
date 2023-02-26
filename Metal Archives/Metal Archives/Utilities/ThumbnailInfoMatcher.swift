//
//  ThumbnailInfoMatcher.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 19/10/2022.
//

import Foundation

final class ThumbnailInfoMatcher {
    private var matchMap = [ThumbnailInfo: String]()

    private init() {}

    static let shared = ThumbnailInfoMatcher()

    func setMatched(thumbnailInfo: ThumbnailInfo, urlString: String) {
        matchMap[thumbnailInfo] = urlString
    }

    func getMatchedUrlString(for thumbnailInfo: ThumbnailInfo) -> String? {
        matchMap[thumbnailInfo]
    }
}
