//
//  Release.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

import Foundation
import Kanna

struct Release {
    let id: String
    let urlString: String
    let bands: [BandLite]
    let coverUrlString: String?
    let title: String
    let type: ReleaseType
    let date: String
    let catalogId: String
    let label: LabelLite
    let format: String
    let additionalHtmlNote: String?
    let reviewCount: Int?
    let rating: Int?
    let otherInfo: [String] // optional info like: version desc, authenticity, limitation...
    let modificationInfo: ModificationInfo
    var isBookmarked: Bool
    let elements: [ReleaseElement]
    let bandMembers: [BandInRelease]
    let guestMembers: [ArtistInRelease]
    let otherStaff: [ArtistInRelease]
    let reviews: [ReviewLite]
}

extension Release {
    private enum InfoType {
        case type, date, catalogId, label, format, reviews, other

        init(string: String) {
            switch string {
            case "Type:": self = .type
            case "Release date:": self = .date
            case "Catalog ID:": self = .catalogId
            case "Label:": self = .label
            case "Format:": self = .format
            case "Reviews:": self = .reviews
            default: self = .other
            }
        }
    }
}

extension Release {
    final class Builder {
        var id: String?
        var urlString: String?
        var bands: [BandLite]?
        var coverUrlString: String?
        var title: String?
        var type: ReleaseType?
        var date: String?
        var catalogId: String?
        var label: LabelLite?
        var format: String?
        var additionalHtmlNote: String?
        var reviewCount: Int?
        var rating: Int?
        var otherInfo: [String]?
        var modificationInfo: ModificationInfo?
        var isBookmarked = false
        var elements: [ReleaseElement]?
        var bandMembers: [BandInRelease]?
        var guestMembers: [ArtistInRelease]?
        var otherStaff: [ArtistInRelease]?
        var reviews: [ReviewLite]?

        func build() -> Release? {
            guard let id = id else {
                Logger.log("[Building Release] id can not be nil.")
                return nil
            }

            guard let urlString = urlString else {
                Logger.log("[Building Release] urlString can not be nil.")
                return nil
            }

            guard let bands = bands else {
                Logger.log("[Building Release] bands can not be nil.")
                return nil
            }

            guard let title = title else {
                Logger.log("[Building Release] title can not be nil.")
                return nil
            }

            guard let type = type else {
                Logger.log("[Building Release] type can not be nil.")
                return nil
            }

            guard let date = date else {
                Logger.log("[Building Release] date can not be nil.")
                return nil
            }

            guard let catalogId = catalogId else {
                Logger.log("[Building Release] catalogId can not be nil.")
                return nil
            }

            guard let label = label else {
                Logger.log("[Building Release] label can not be nil.")
                return nil
            }

            guard let format = format else {
                Logger.log("[Building Release] format can not be nil.")
                return nil
            }

            guard let otherInfo = otherInfo else {
                Logger.log("[Building Release] otherInfo can not be nil.")
                return nil
            }

            guard let modificationInfo = modificationInfo else {
                Logger.log("[Building Release] modificationInfo can not be nil.")
                return nil
            }

            guard let elements = elements else {
                Logger.log("[Building Release] elements can not be nil.")
                return nil
            }

            guard let bandMembers = bandMembers else {
                Logger.log("[Building Release] bandMembers can not be nil.")
                return nil
            }

            guard let reviews = reviews else {
                Logger.log("[Building Release] reviews can not be nil.")
                return nil
            }

            return Release(id: id,
                           urlString: urlString,
                           bands: bands,
                           coverUrlString: coverUrlString,
                           title: title,
                           type: type,
                           date: date,
                           catalogId: catalogId,
                           label: label,
                           format: format,
                           additionalHtmlNote: additionalHtmlNote,
                           reviewCount: reviewCount,
                           rating: rating,
                           otherInfo: otherInfo,
                           modificationInfo: modificationInfo,
                           isBookmarked: isBookmarked,
                           elements: elements,
                           bandMembers: bandMembers,
                           guestMembers: guestMembers ?? [],
                           otherStaff: otherStaff ?? [],
                           reviews: reviews)
        }
    }
}

fileprivate enum ReleaseMemberType {
    case bandMember, guest, misc
}

extension Release {
    // swiftlint:disable identifier_name
    init?(data: Data) {
        guard let htmlString = String(data: data, encoding: String.Encoding.utf8),
              let html = try? Kanna.HTML(html: htmlString, encoding: String.Encoding.utf8) else {
            return nil
        }

        let builder = Builder()

        // See Band's init function for explication
        if let a = html.css("a").first(where: { $0["id"] == "bookmark" }), let aClass = a["class"] {
            builder.isBookmarked = aClass.contains("ui-state-active")
        }

        if let h1 = html.at_css("h1"), let a = h1.at_css("a") {
            let urlString = a["href"]
            builder.id = urlString?.components(separatedBy: "/").last
            builder.urlString = urlString
            builder.title = a.text
        }

        if let h2 = html.at_css("h2") {
            var bands = [BandLite]()
            for a in h2.css("a") {
                if let bandName = a.text, let bandUrlString = a["href"],
                   let band = BandLite(urlString: bandUrlString, name: bandName) {
                    bands.append(band)
                }
            }
            builder.bands = bands
        }

        for div in html.css("div") {
            if let divId = div["id"] {
                switch divId {
                case "album_info":
                    Self.parseAlbumInfo(from: div, builder: builder)

                case "album_members_lineup":
                    Self.parseMembers(from: div, builder: builder, type: .bandMember)

                case "album_members_guest":
                    Self.parseMembers(from: div, builder: builder, type: .guest)

                case "album_members_misc":
                    Self.parseMembers(from: div, builder: builder, type: .misc)

                case "album_tabs_notes":
                    builder.additionalHtmlNote = div.innerHTML

                case "auditTrail":
                    if let htmlString = div.innerHTML {
                        builder.modificationInfo = ModificationInfo(from: htmlString)
                    }

                default: break
                }
            } else if let divClass = div["class"], divClass == "album_img" {
                builder.coverUrlString = div.at_css("a")?["href"]
            }
        }

        for table in html.css("table") {
            if table["class"] == "display table_lyrics" {
                var elements = [ReleaseElement]()

                for tr in table.css("tr") {
                    guard let trText = tr.text else { continue }
                    switch tr["class"] {
                    case "sideRow":
                        elements.append(.side(title: trText))

                    case "discRow":
                        elements.append(.disc(title: trText))

                    case "even", "odd":
                        let trackBuilder = ReleaseElement.TrackBuilder()
                        for (index, td) in tr.css("td").enumerated() {
                            switch index {
                            case 0: trackBuilder.number = td.text
                            case 1: trackBuilder.title = td.text
                            case 2: trackBuilder.length = td.text
                            case 3:
                                trackBuilder.isInstrumental = td.text?.contains("instrumental") == true
                                trackBuilder.lyricId = td.at_css("a")?["href"]?.removeAll(string: "#")
                            default: break
                            }
                        }
                        if let track = trackBuilder.build() {
                            elements.append(track)
                        }

                    default: break
                    }
                }

                builder.elements = elements
            }

            if table["id"] == "review_list" {
                var reviews = [ReviewLite]()
                for tr in table.css("tr") {
                    let reviewBuilder = ReviewLite.Builder()
                    for (index, td) in tr.css("td").enumerated() {
                        switch index {
                        case 0: reviewBuilder.urlString = td.at_css("a")?["href"]
                        case 1: reviewBuilder.title = td.text
                        case 2: reviewBuilder.rating = td.text?.removeAll(string: "%").toInt()
                        case 3: reviewBuilder.author = UserLite(from: td.innerHTML ?? "")
                        case 4: reviewBuilder.date = td.text
                        default: break
                        }
                    }
                    if let review = reviewBuilder.build() {
                        reviews.append(review)
                    }
                }
                builder.reviews = reviews
            }
        }

        guard let release = builder.build() else { return nil }
        self = release
    }

    private static func parseAlbumInfo(from document: XMLElement, builder: Builder) {
        var infoTypes = [Release.InfoType]()
        var otherInfo = [String]()

        for dt in document.css("dt") {
            if let dtText = dt.text {
                infoTypes.append(.init(string: dtText))
            }
        }

        for (index, dd) in document.css("dd").enumerated() {
            if let ddText = dd.text {
                switch infoTypes[index] {
                case .type: builder.type = ReleaseType(typeString: ddText)
                case .date: builder.date = ddText
                case .catalogId: builder.catalogId = ddText
                case .label:
                    if let a = dd.at_css("a"), let labelName = a.text,
                       let labelUrlString = a["href"] {
                        let thumbnailInfo = ThumbnailInfo(urlString: labelUrlString, type: .label)
                        builder.label = LabelLite(thumbnailInfo: thumbnailInfo, name: labelName)
                    }
                case .format: builder.format = ddText
                case .reviews:
                    let trimmedDdText = ddText.trimmingCharacters(in: .whitespacesAndNewlines)
                    builder.reviewCount = trimmedDdText.components(separatedBy: " ").first?.toInt()
                    builder.rating = trimmedDdText.components(separatedBy: " ").last?
                        .removeAll(string: "%)").toInt()
                case .other: otherInfo.append(ddText)
                }
            }
        }

        builder.otherInfo = otherInfo
    }

    private static func parseMembers(from document: XMLElement, builder: Builder, type: ReleaseMemberType) {
        var bands = [BandInRelease]()
        var members = [ArtistInRelease]()
        var currentBandName: String?

        for tr in document.css("tr") {
            if tr.css("td").count == 1 {
                currentBandName = tr.at_css("td")?.text
                continue
            }

            if let bandName = currentBandName, !members.isEmpty {
                bands.append(.init(name: bandName, members: members))
                members = []
                currentBandName = nil
            }

            let artistBuilder = ArtistInRelease.Builder()
            for (index, td) in tr.css("td").enumerated() {
                switch index {
                case 0:
                    if let a = td.at_css("a"), let urlString = a["href"] {
                        artistBuilder.thumbnailInfo = ThumbnailInfo(urlString: urlString, type: .artist)
                        artistBuilder.name = a.text
                    }
                    artistBuilder.additionalDetail = td.text?.subString(after: "(", before: ")")
                case 1:
                    artistBuilder.instruments = td.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                default: break
                }
            }

            switch type {
            case .bandMember: artistBuilder.lineUpType = .members
            case .guest: artistBuilder.lineUpType = .guest
            case .misc: artistBuilder.lineUpType = .other
            }

            if let artist = artistBuilder.build() {
                members.append(artist)
            }
        }

        switch type {
        case .bandMember:
            if bands.isEmpty {
                bands.append(.init(name: builder.bands?.first?.name, members: members))
            }
            builder.bandMembers = bands
        case .guest: builder.guestMembers = members
        case .misc: builder.otherStaff = members
        }
    }
}
