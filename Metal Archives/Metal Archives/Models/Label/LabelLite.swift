//
//  LabelLite.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

import Kanna

struct LabelLite: OptionalThumbnailable {
    let thumbnailInfo: ThumbnailInfo?
    let name: String
}

extension LabelLite {
    init?(aTag: XMLElement) {
        guard let urlString = aTag["href"], let name = aTag.text else { return nil }
        self.thumbnailInfo = .init(urlString: urlString, type: .label)
        self.name = name
    }
}

extension LabelLite: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        if let lhsThumbnailInfo = lhs.thumbnailInfo,
           let rhsThumbnailInfo = rhs.thumbnailInfo {
            return lhsThumbnailInfo.urlString == rhsThumbnailInfo.urlString
        }
        return lhs.name == rhs.name
    }
}

extension LabelLite: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(thumbnailInfo?.urlString ?? "")
    }
}
