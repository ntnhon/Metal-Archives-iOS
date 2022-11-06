//
//  Review.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 06/11/2022.
//

import Foundation
import Kanna

struct Review {
    let band: BandLite
    let release: ReleaseLite
    let coverPhotoUrlString: String?
    let title: String
    let rating: Int
    let user: UserLite
    let date: String
    let baseVersion: ReleaseLite?
    let content: String
}

extension Review {
    final class Builder {
        var band: BandLite?
        var release: ReleaseLite?
        var coverPhotoUrlString: String?
        var title: String?
        var rating: Int?
        var user: UserLite?
        var date: String?
        var baseVersion: ReleaseLite?
        var content: String?

        func build() -> Review? {
            guard let band else {
                Logger.log("[Building Review] band can not be nil")
                return nil
            }

            guard let release else {
                Logger.log("[Building Review] release can not be nil")
                return nil
            }

            guard let title else {
                Logger.log("[Building Review] title can not be nil")
                return nil
            }

            guard let rating else {
                Logger.log("[Building Review] rating can not be nil")
                return nil
            }

            guard let user else {
                Logger.log("[Building Review] user can not be nil")
                return nil
            }

            guard let date else {
                Logger.log("[Building Review] date can not be nil")
                return nil
            }

            guard let content else {
                Logger.log("[Building Review] content can not be nil")
                return nil
            }

            return .init(band: band,
                         release: release,
                         coverPhotoUrlString: coverPhotoUrlString,
                         title: title,
                         rating: rating,
                         user: user,
                         date: date,
                         baseVersion: baseVersion,
                         content: content)
        }
    }
}

extension Review: HTMLParsable {
    init(data: Data) throws {
        let html = try Kanna.HTML(html: data, encoding: .utf8)
        let builder = Builder()

        for div in html.css("div") {
            switch div["id"] {
            case "album_content":
                Self.parseBandAndRelease(from: div, builder: builder)
            default:
                break
            }

            switch div["class"] {
            case "reviewBox":
                Self.parseOtherContent(from: div, builder: builder)
            default:
                break
            }
        }

        guard let review = builder.build() else {
            throw MAError.parseFailure("\(Self.self)")
        }
        self = review
    }

    private static func parseBandAndRelease(from div: XMLElement, builder: Builder) {
        if let h1 = div.at_css("h1"),
           let aTag = h1.at_css("a"),
           let releaseTitle = aTag.text,
           let releaseUrlString = aTag["href"] {
            builder.release = .init(urlString: releaseUrlString, title: releaseTitle)
        }

        if let h2 = div.at_css("h2"),
           let aTag = h2.at_css("a"),
           let bandName = aTag.text,
           let bandUrlString = aTag["href"] {
            builder.band = .init(urlString: bandUrlString, name: bandName)
        }
    }

    private static func parseOtherContent(from div: XMLElement, builder: Builder) {
        if let h3 = div.at_css("h3"),
           let titleAndRating = h3.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            Self.parseTitleAndRating(titleAndRating, builder: builder)
        }

        for div in div.css("div") {
            switch div["class"] {
            case "reviewContent":
                builder.content = div.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            case .none:
                builder.date = div.innerHTML?.subString(after: ", ", before: "<br>")?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                let aTags = div.css("a")
                for (index, aTag) in aTags.enumerated() {
                    if let urlString = aTag["href"],
                       let text = aTag.text {
                        if index == 0 {
                            builder.user = .init(name: text, urlString: urlString)
                        } else {
                            builder.baseVersion = .init(urlString: urlString, title: text)
                        }
                    }
                }
            default:
                break
            }
        }
    }

    private static func parseTitleAndRating(_ titleAndRating: String, builder: Builder) {
        guard let hyphenIndex = titleAndRating.lastIndex(of: "-") else { return }
        let title = titleAndRating[titleAndRating.startIndex..<hyphenIndex].trimmingCharacters(in: .whitespaces)
        let rating = titleAndRating[hyphenIndex..<titleAndRating.endIndex]
            .replacingOccurrences(of: "-", with: "")
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: "%", with: "")
        builder.title = title
        builder.rating = Int(rating)
    }
}
