//
//  Band.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

import Foundation
import Kanna

struct Band {
    let id: String
    let urlString: String
    let name: String
    let country: Country
    let genre: String
    let status: BandStatus
    let location: String
    let yearOfCreation: String
    let yearsActive: String
    let oldBands: [BandLite]
    let lyricalTheme: String
    let lastLabel: LabelLite
    let logoUrlString: String?
    let photoUrlString: String?
    let modificationInfo: ModificationInfo
    var isBookmarked: Bool
    let isLastKnownLineUp: Bool
    let currentLineUp: [ArtistInBand] // or last known
    let pastMembers: [ArtistInBand]
    let liveMusicians: [ArtistInBand]

    var hasPhoto: Bool { photoUrlString != nil }
    var hasLogo: Bool { logoUrlString != nil }
}

extension Band {
    final class Builder {
        var id: String?
        var urlString: String?
        var name: String?
        var country: Country?
        var genre: String?
        var status: BandStatus?
        var location: String?
        var yearOfCreation: String?
        var yearsActive: String?
        var oldBands: [BandLite]?
        var lyricalTheme: String?
        var lastLabel: LabelLite?
        var logoUrlString: String?
        var photoUrlString: String?
        var modificationInfo: ModificationInfo?
        var isBookmarked = false
        var isLastKnownLineUp = false
        var currentLineUp: [ArtistInBand] = []
        var pastMembers: [ArtistInBand] = []
        var liveMusicians: [ArtistInBand] = []

        func build() -> Band? {
            guard let id = id else {
                Logger.log("[Building Band] id can not be nil.")
                return nil
            }

            guard let urlString = urlString else {
                Logger.log("[Building Band] urlString can not be nil.")
                return nil
            }

            guard let name = name else {
                Logger.log("[Building Band] name can not be nil.")
                return nil
            }

            guard let country = country else {
                Logger.log("[Building Band] country can not be nil.")
                return nil
            }

            guard let genre = genre else {
                Logger.log("[Building Band] genre can not be nil.")
                return nil
            }

            guard let status = status else {
                Logger.log("[Building Band] status can not be nil.")
                return nil
            }

            guard let location = location else {
                Logger.log("[Building Band] location can not be nil.")
                return nil
            }

            guard let yearOfCreation = yearOfCreation else {
                Logger.log("[Building Band] yearOfCreation can not be nil.")
                return nil
            }

            guard let yearsActive = yearsActive else {
                Logger.log("[Building Band] yearsActive can not be nil.")
                return nil
            }

            guard let oldBands = oldBands else {
                Logger.log("[Building Band] oldBands can not be nil.")
                return nil
            }

            guard let lyricalTheme = lyricalTheme else {
                Logger.log("[Building Band] lyricalTheme can not be nil.")
                return nil
            }

            guard let lastLabel = lastLabel else {
                Logger.log("[Building Band] lastLabel can not be nil.")
                return nil
            }

            guard let modificationInfo = modificationInfo else {
                Logger.log("[Building Band] modificationInfo can not be nil.")
                return nil
            }

            return Band(id: id,
                        urlString: urlString,
                        name: name,
                        country: country,
                        genre: genre,
                        status: status,
                        location: location,
                        yearOfCreation: yearOfCreation,
                        yearsActive: yearsActive,
                        oldBands: oldBands,
                        lyricalTheme: lyricalTheme,
                        lastLabel: lastLabel,
                        logoUrlString: logoUrlString,
                        photoUrlString: photoUrlString,
                        modificationInfo: modificationInfo,
                        isBookmarked: isBookmarked,
                        isLastKnownLineUp: isLastKnownLineUp,
                        currentLineUp: currentLineUp,
                        pastMembers: pastMembers,
                        liveMusicians: liveMusicians)
        }
    }
}

fileprivate enum BandMemberType {
    case current, past, live
}

extension Band: HTMLParsable {
    // swiftlint:disable identifier_name
    // Declare extra init in an extension in order to preserve the default initializer
    init(data: Data) throws {
        guard let htmlString = String(data: data, encoding: String.Encoding.utf8),
              let html = try? Kanna.HTML(html: htmlString, encoding: String.Encoding.utf8) else {
            throw MAError.parseFailure(String(describing: Self.self))
        }

        let builder = Band.Builder()

        if let a = html.css("a").first(where: { $0["id"] == "bookmark" }), let aClass = a["class"] {
            builder.isBookmarked = aClass.contains("ui-state-active")
        }

        if let h1 = html.at_css("h1"), let a = h1.at_css("a") {
            let urlString = a["href"]
            builder.id = urlString?.components(separatedBy: "/").last
            builder.urlString = urlString
            builder.name = a.text
        }

        if let tr = html.css("tr").first(where: { $0["class"] == "lineupHeaders" }),
           let trText = tr.text {
            builder.isLastKnownLineUp = trText.contains("Last known")
        }

        for div in html.css("div") {
            if let divId = div["id"] {
                switch divId {
                case "band_stats": Self.parseBandStatsDiv(div, to: builder)
                case "auditTrail": builder.modificationInfo = ModificationInfo(from: div.innerHTML ?? "")
                case "band_tab_members_current": Self.parseMembersDiv(div, to: builder, ofType: .current)
                case "band_tab_members_past": Self.parseMembersDiv(div, to: builder, ofType: .past)
                case "band_tab_members_live": Self.parseMembersDiv(div, to: builder, ofType: .live)
                default: break
                }
            } else if let divClass = div["class"] {
                switch divClass {
                case "band_name_img":
                    builder.logoUrlString = div.at_css("a")?["href"]

                case "band_img":
                    builder.photoUrlString = div.at_css("a")?["href"]
                default: break
                }
            }
        }

        guard let band = builder.build() else {
            throw MAError.parseFailure(String(describing: Self.self))
        }
        self = band
    }

    private static func parseBandStatsDiv(_ div: XMLElement, to builder: Builder) {
        for dl in div.css("dl") {
            switch dl["class"] {
            case "float_left":
                for (index, dd) in dl.css("dd").enumerated() {
                    switch index {
                    case 0:
                        // Country of origin
                        if let countryName = dd.at_css("a")?.text {
                            builder.country = CountryManager.shared.country(by: \.name, value: countryName)
                        }
                    case 1:
                        // Location
                        builder.location = dd.text
                    case 2:
                        // Status
                        if let statusString = dd.text {
                            builder.status = BandStatus(rawValue: statusString)
                        }
                    case 3:
                        // Formed in
                        builder.yearOfCreation = dd.text
                    default: break
                    }
                }

            case "float_right":
                for (index, dd) in dl.css("dd").enumerated() {
                    switch index {
                    case 0:
                        // Genre
                        builder.genre = dd.text
                    case 1:
                        // Lyrical themes
                        builder.lyricalTheme = dd.text
                    case 2:
                        // Last label
                        if let a = dd.at_css("a"), let labelName = a.text, let labelUrlString = a["href"],
                           let thumbnailInfo = ThumbnailInfo(urlString: labelUrlString, type: .label) {
                            builder.lastLabel = .init(thumbnailInfo: thumbnailInfo, name: labelName)
                        } else if let labelName = dd.text {
                            builder.lastLabel = .init(thumbnailInfo: nil, name: labelName)
                        }
                    default: break
                    }
                }

            case "clear":
                // Years active
                if let dd = dl.at_css("dd") {
                    builder.yearsActive = dd.text?
                        .replacingOccurrences(of: "\n", with: " ")
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    // Parse old bands
                    var oldBands = [BandLite]()
                    for a in dd.css("a") {
                        if let bandName = a.text, let bandUrlString = a["href"],
                           let band = BandLite(urlString: bandUrlString, name: bandName) {
                            oldBands.append(band)
                        }
                    }
                    builder.oldBands = oldBands
                }
            default: break
            }
        }
    }

    private static func parseMembersDiv(_ div: XMLElement,
                                        to builder: Builder,
                                        ofType memberType: BandMemberType) {
        var lineUp = [ArtistInBand]()
        var lastArtistBuilder: ArtistInBand.Builder?

        for tr in div.css("tr") {
            switch tr["class"] {
            case "lineupRow":
                if lastArtistBuilder?.name != nil && lastArtistBuilder?.bands == nil {
                    lastArtistBuilder?.bands = []
                    lastArtistBuilder?.seeAlso = nil
                }

                if let artist = lastArtistBuilder?.build() {
                    lineUp.append(artist)
                }

                lastArtistBuilder = ArtistInBand.Builder()
                for (index, td) in tr.css("td").enumerated() {
                    switch index {
                    case 0:
                        // Get name and url
                        if let a = td.at_css("a"), let name = a.text, let urlString = a["href"] {
                            lastArtistBuilder?.name = name
                            lastArtistBuilder?.thumbnailInfo = ThumbnailInfo(urlString: urlString, type: .artist)
                        }
                    case 1:
                        // Get instruments
                        lastArtistBuilder?.instruments = td.text?.strippedHtmlString()
                    default:
                        break
                    }
                }

            case "lineupBandsRow":
                // Get ex-bands
                var exBands = [BandLite]()
                if let td = tr.at_css("td") {
                    lastArtistBuilder?.seeAlso = td.text?.strippedHtmlString()
                    for a in td.css("a") {
                        if let bandName = a.text, let bandUrlString = a["href"],
                           let band = BandLite(urlString: bandUrlString, name: bandName) {
                            exBands.append(band)
                        }
                    }
                }
                lastArtistBuilder?.bands = exBands

                if let artist = lastArtistBuilder?.build() {
                    lineUp.append(artist)
                }

                lastArtistBuilder = nil

            default: break
            }
        }

        switch memberType {
        case .current: builder.currentLineUp = lineUp
        case .past: builder.pastMembers = lineUp
        case .live: builder.liveMusicians = lineUp
        }
    }
}

extension Band {
    // swiftlint:disable force_try
    // swiftlint:disable force_unwrapping
    static let death = try! Band(data: try! Data.fromHtml(fileName: "Death")!)
}
