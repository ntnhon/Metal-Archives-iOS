//
//  BandLite.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

import SwiftUI

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

extension BandLite: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.thumbnailInfo.id == rhs.thumbnailInfo.id
    }
}

extension BandLite: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(thumbnailInfo)
    }
}

extension BandLite: Identifiable {
    var id: Int { hashValue }
}

// swiftlint:disable force_unwrapping
extension BandLite {
    static var controlDenied: BandLite {
        .init(urlString: "https://www.metal-archives.com/bands/Control_Denied/549",
              name: "Control Denied")!
    }

    static var mantas: BandLite {
        .init(urlString: "https://www.metal-archives.com/bands/Mantas/35328",
              name: "Mantas")!
    }

    static var slaughter: BandLite {
        .init(urlString: "https://www.metal-archives.com/bands/Slaughter/376",
              name: "Slaughter")!
    }

    static var voodoocult: BandLite {
        .init(urlString: "https://www.metal-archives.com/bands/Voodoocult/1599",
              name: "Voodoocult")!
    }
}
// swiftlint:enable force_unwrapping

struct BandExtraLite: OptionalThumbnailable {
    let thumbnailInfo: ThumbnailInfo?
    let name: String

    init(urlString: String?, name: String) {
        if let urlString {
            self.thumbnailInfo = ThumbnailInfo(urlString: urlString, type: .bandLogo)
        } else {
            self.thumbnailInfo = nil
        }
        self.name = name
    }

    func toBandLite() -> BandLite? {
        guard let urlString = thumbnailInfo?.urlString else { return nil }
        return .init(urlString: urlString, name: name)
    }
}

extension BandExtraLite: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(thumbnailInfo)
        hasher.combine(name)
    }
}

extension Array where Element == BandLite {
    func generateTexts(fontWeight: Font.Weight,
                       foregroundColor: Color) -> [Text] {
        var texts = [Text]()
        for (index, band) in enumerated() {
            texts.append(Text(band.name).fontWeight(fontWeight).foregroundColor(foregroundColor))
            if index != count - 1 {
                texts.append(Text(" / ").fontWeight(fontWeight))
            }
        }
        return texts
    }
}
