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
        if let urlString = urlString {
            self.thumbnailInfo = ThumbnailInfo(urlString: urlString, type: .bandLogo)
        } else {
            self.thumbnailInfo = nil
        }
        self.name = name
    }
}
