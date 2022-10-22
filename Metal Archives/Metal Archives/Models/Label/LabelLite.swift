//
//  LabelLite.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

struct LabelLite: OptionalThumbnailable {
    let thumbnailInfo: ThumbnailInfo?
    let name: String
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
