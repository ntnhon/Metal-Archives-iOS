//
//  BandLite.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

import Foundation

struct BandLite: Thumbnailable {
    let thumbnailInfo: ThumbnailInfo
    let name: String

    init?(urlString: String, name: String) {
        guard let thumbnailInfo = ThumbnailInfo(urlString: urlString, type: .bandLogo) else {
            return nil
        }
        self.thumbnailInfo = thumbnailInfo
        self.name = name
    }
}
