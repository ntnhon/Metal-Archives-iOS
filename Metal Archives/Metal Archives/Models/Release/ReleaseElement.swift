//
//  ReleaseElement.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 24/05/2021.
//

enum ReleaseElement {
    // swiftlint:disable:next enum_case_associated_values_count
    case song(number: String, title: String, length: String, lyricId: String?, isInstrumental: Bool)
    case side(value: String)
    case disc(value: String)
    case length(value: String)
}

extension ReleaseElement {
    final class TrackBuilder {
        var number: String?
        var title: String?
        var length: String?
        var lyricId: String?
        var isInstrumental = false

        func build() -> ReleaseElement? {
            guard let number = number else {
                Logger.log("[Building ReleaseElement] number can not be nil")
                return nil
            }

            guard let title = title else {
                Logger.log("[Building ReleaseElement] title can not be nil")
                return nil
            }

            guard let length = length else {
                Logger.log("[Building ReleaseElement] length can not be nil")
                return nil
            }

            return ReleaseElement.song(number: number,
                                       title: title,
                                       length: length,
                                       lyricId: lyricId,
                                       isInstrumental: isInstrumental)
        }
    }
}
