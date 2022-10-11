//
//  ReleaseElement.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 24/05/2021.
//

enum ReleaseElement {
    case song(Song)
    case side(String)
    case disc(String)
    case length(String)
}

struct Song {
    let number: String
    let title: String
    let length: String
    let lyricId: String?
    let isInstrumental: Bool

    final class Builder {
        var number: String?
        var title: String?
        var length: String?
        var lyricId: String?
        var isInstrumental = false

        func build() -> Song? {
            guard let number = number else {
                Logger.log("[Building Song] number can not be nil")
                return nil
            }

            guard let title = title else {
                Logger.log("[Building Song] title can not be nil")
                return nil
            }

            guard let length = length else {
                Logger.log("[Building Song] length can not be nil")
                return nil
            }

            return .init(number: number,
                         title: title,
                         length: length,
                         lyricId: lyricId,
                         isInstrumental: isInstrumental)
        }
    }
}
