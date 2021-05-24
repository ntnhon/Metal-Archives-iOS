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
    let currentLineUp: [ArtistLite]
    let pastMembers: [ArtistLite]
    let liveMusicians: [ArtistLite]
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
        var currentLineUp: [ArtistLite]?
        var pastMembers: [ArtistLite]?
        var liveMusicians: [ArtistLite]?

        func build() -> Band? {
            guard let id = id else {
                Logger.log("id can not be nil.")
                return nil
            }

            guard let urlString = urlString else {
                Logger.log("urlString can not be nil.")
                return nil
            }

            guard let name = name else {
                Logger.log("name can not be nil.")
                return nil
            }

            guard let country = country else {
                Logger.log("country can not be nil.")
                return nil
            }

            guard let genre = genre else {
                Logger.log("genre can not be nil.")
                return nil
            }

            guard let status = status else {
                Logger.log("status can not be nil.")
                return nil
            }

            guard let location = location else {
                Logger.log("location can not be nil.")
                return nil
            }

            guard let yearOfCreation = yearOfCreation else {
                Logger.log("yearOfCreation can not be nil.")
                return nil
            }

            guard let yearsActive = yearsActive else {
                Logger.log("yearsActive can not be nil.")
                return nil
            }

            guard let oldBands = oldBands else {
                Logger.log("oldBands can not be nil.")
                return nil
            }

            guard let lyricalTheme = lyricalTheme else {
                Logger.log("lyricalTheme can not be nil.")
                return nil
            }

            guard let lastLabel = lastLabel else {
                Logger.log("lastLabel can not be nil.")
                return nil
            }

            guard let modificationInfo = modificationInfo else {
                Logger.log("modificationInfo can not be nil.")
                return nil
            }

            guard let currentLineUp = currentLineUp else {
                Logger.log("currentLineUp can not be nil.")
                return nil
            }

            guard let pastMembers = pastMembers else {
                Logger.log("pastMembers can not be nil.")
                return nil
            }

            guard let liveMusicians = liveMusicians else {
                Logger.log("liveMusicians can not be nil.")
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

fileprivate enum MemberType {
    case current, past, live
}

extension Band {
    // swiftlint:disable identifier_name
    // Declare extra init in an extension in order to preserve the default initializer
    init?(data: Data) {
        guard let htmlString = String(data: data, encoding: String.Encoding.utf8),
              let html = try? Kanna.HTML(html: htmlString, encoding: String.Encoding.utf8) else {
            return nil
        }

        let builder = Band.Builder()

        // Check if band is bookmarked or not
        // look for the a tag with id "bookmark"
        // Bookmarked: <a id="bookmark" class="iconContainer ui-state-active ...
        // Not bookmarked: <a id="bookmark" class="iconContainer ui-state-default ...
        // Not logged in: the tag a with id "bookmark" doesn't exist
        if let a = html.css("a").first(where: { $0["id"] == "bookmark" }), let aClass = a["class"] {
            builder.isBookmarked = aClass.contains("ui-state-active")
        }

        // Look for band name, id and url in h1 tag (there is only one h1 tag)
        // <h1 class="band_name"><a href="https://www.metal-archives.com/bands/Death/141">Death</a></h1>
        if let h1 = html.at_css("h1"), let a = h1.at_css("a") {
            let urlString = a["href"]
            builder.id = urlString?.components(separatedBy: "/").last
            builder.urlString = urlString
            builder.name = a.text
        }

        // Find out if currentLineUp is "current" or "last known"
        // base of the first tr tag with class "lineupHeaders"
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
                // swiftlint:disable line_length
                switch divClass {
                case "band_name_img":
                    /*
                     <div class="band_name_img">
                         <a class="image" id="logo" title="Death" href="https://www.metal-archives.com/images/1/4/1/141_logo.png?3006"><img src="https://www.metal-archives.com/images/1/4/1/141_logo.png?3006" title="Click to zoom" alt="Death - Logo" border="0" /></a>
                         </div>
                     */
                    builder.logoUrlString = div.at_css("a")?["href"]

                case "band_img":
                /*
                 <div class="band_img">
                     <a class="image" id="photo" title="Death" href="https://www.metal-archives.com/images/1/4/1/141_photo.jpg?5804"><img src="https://www.metal-archives.com/images/1/4/1/141_photo.jpg?5804" title="Click to zoom" alt="Death - Photo" border="0" /></a>
                 </div>
                 */
                    builder.photoUrlString = div.at_css("a")?["href"]
                default: break
                }
                // swiftlint:enable line_length
            }
        }

        guard let band = builder.build() else { return nil }
        self = band
    }

    private static func parseBandStatsDiv(_ div: XMLElement, to builder: Builder) {
        // swiftlint:disable line_length
        /*
         <div id="band_stats">
             <dl class="float_left">
                 <dt>Country of origin:</dt>
                 <dd><a href="https://www.metal-archives.com/lists/US">United States</a></dd>
                 <dt>Location:</dt>
                 <dd>Altamonte Springs, Florida</dd>
                 <dt>Status:</dt>
                 <dd class="split_up">Split-up</dd>
                 <dt>Formed in:</dt>
                 <dd>1984</dd>
             </dl>
             <dl class="float_right">
                 <dt>Genre:</dt>
                 <dd>Death Metal (early); Progressive Death Metal (later)</dd>
                 <dt>Lyrical themes:</dt>
                 <dd>Death, Gore (early); Society, Enlightenment (later)</dd>
                 <dt>Last label:</dt>
                 <dd><a href="https://www.metal-archives.com/labels/Nuclear_Blast/2">Nuclear Blast</a></dd>
             </dl>
             <dl style="width: 100%;" class="clear">
                 <dt>Years active:</dt>
                 <dd>
                 1983-1984 (as <a href="https://www.metal-archives.com/bands/Mantas/35328">Mantas</a>), 1984-2001 </dd>
             </dl>
         </div>
         */
        // swiftlint:enable line_length
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
                        }
                    default: break
                    }
                }

            case "clear":
                // Years active
                if let dd = dl.at_css("dd") {
                    builder.yearsActive = dd.text?.trimmingCharacters(in: .whitespacesAndNewlines)
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
                                        ofType memberType: MemberType) {
        // swiftlint:disable line_length
        /*
         <div id="band_tab_members_current">
             <div class="ui-tabs-panel-content">
                 <table class="display lineupTable" cellpadding="0" cellspacing="0">
                     <tr class="lineupRow">
                         <td width="200" valign="top">
                             <a href="https://www.metal-archives.com/artists/Chuck_Schuldiner/3012" class="bold">Chuck Schuldiner</a>
                         </td>
                         <td>
                             Guitars, Vocals&nbsp;(1984-2001) </td>
                     </tr>
                     <tr class="lineupBandsRow">
                         <td colspan="2">
                             (R.I.P. 2001) See also: ex-
                             <a href="https://www.metal-archives.com/bands/Control_Denied/549">Control Denied</a>, ex-<a href="https://www.metal-archives.com/bands/Mantas/35328">Mantas</a>, ex-<a href="https://www.metal-archives.com/bands/Slaughter/376">Slaughter</a>,
                             ex-<a href="https://www.metal-archives.com/bands/Voodoocult/1599">Voodoocult</a> </td>
                     </tr>
                 </table>
             </div>
         </div>
         */
        // swiftlint:enable line_length
        var lineUp = [ArtistLite]()
        var lastArtistBuilder: ArtistLite.Builder?

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

                lastArtistBuilder = ArtistLite.Builder()
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
                        lastArtistBuilder?.instruments = td.text?.removeHtmlTagsAndNoisySpaces()
                    default:
                        break
                    }
                }

            case "lineupBandsRow":
                // Get ex-bands
                var exBands = [BandLite]()
                if let td = tr.at_css("td") {
                    lastArtistBuilder?.seeAlso = td.text?.removeHtmlTagsAndNoisySpaces()
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
