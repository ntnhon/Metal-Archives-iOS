//
//  ReleaseLite.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 29/05/2021.
//

import Foundation

struct ReleaseLite: Thumbnailable {
    let thumbnailInfo: ThumbnailInfo
    let title: String

    init?(urlString: String, title: String) {
        guard let thumbnailInfo = ThumbnailInfo(urlString: urlString, type: .release) else {
            return nil
        }
        self.thumbnailInfo = thumbnailInfo
        self.title = title
    }
}

extension ReleaseLite: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(thumbnailInfo)
        hasher.combine(title)
    }
}
