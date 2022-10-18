//
//  Artist.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 29/05/2021.
//

import Foundation
import Kanna

// swiftlint:disable identifier_name
struct Artist {
    let artistName: String
    let realFullName: String
    let age: String
    let origin: String
    let gender: String
    let rip: String?
    let causeOfDeath: String?
    let photoUrlString: String?
    let biographyHtmlString: String?
    let hasMoreBiography: Bool
    let triviaHtmlString: String?
    var isBookmarked: Bool
    let modificationInfo: ModificationInfo
    let activeRoles: [RoleInBand]
    let pastRoles: [RoleInBand]
    let liveRoles: [RoleInBand]
    let guestSessionRoles: [RoleInBand]
    let miscStaffRoles: [RoleInBand]
}

extension Artist {
    private enum InfoType {
        case realFullName, placeOfOrigin, age, gender, rip, causeOfDeath

        init?(string: String) {
            switch string {
            case "Real/full name:": self = .realFullName
            case "Place of origin:": self = .placeOfOrigin
            case "Age:": self = .age
            case "Gender:": self = .gender
            case "R.I.P.: ", "R.I.P.:": self = .rip
            case "Died of:": self = .causeOfDeath
            default: return nil
            }
        }
    }

    private enum RoleType {
        case active, past, live, guestSession, misc
    }
}

extension Artist {
    final class Builder {
        var artistName: String?
        var realFullName: String?
        var age: String?
        var origin: String?
        var gender: String?
        var rip: String?
        var causeOfDeath: String?
        var photoUrlString: String?
        var biographyHtmlString: String?
        var hasMoreBiography = false
        var triviaHtmlString: String?
        var isBookmarked = false
        var modificationInfo: ModificationInfo?
        var activeRoles: [RoleInBand]?
        var pastRoles: [RoleInBand]?
        var liveRoles: [RoleInBand]?
        var guestSessionRoles: [RoleInBand]?
        var miscStaffRoles: [RoleInBand]?

        func build() -> Artist? {
            guard let artistName else {
                Logger.log("[Building Artist] artistName can not be nil")
                return nil
            }

            guard let realFullName else {
                Logger.log("[Building Artist] realFullName can not be nil")
                return nil
            }

            guard let age else {
                Logger.log("[Building Artist] age can not be nil")
                return nil
            }

            guard let origin else {
                Logger.log("[Building Artist] origin can not be nil")
                return nil
            }

            guard let gender else {
                Logger.log("[Building Artist] gender can not be nil")
                return nil
            }

            guard let modificationInfo else {
                Logger.log("[Building Artist] modificationInfo can not be nil")
                return nil
            }

            return Artist(artistName: artistName,
                          realFullName: realFullName,
                          age: age,
                          origin: origin,
                          gender: gender,
                          rip: rip,
                          causeOfDeath: causeOfDeath,
                          photoUrlString: photoUrlString,
                          biographyHtmlString: biographyHtmlString,
                          hasMoreBiography: hasMoreBiography,
                          triviaHtmlString: triviaHtmlString,
                          isBookmarked: isBookmarked,
                          modificationInfo: modificationInfo,
                          activeRoles: activeRoles ?? [],
                          pastRoles: pastRoles ?? [],
                          liveRoles: liveRoles ?? [],
                          guestSessionRoles: guestSessionRoles ?? [],
                          miscStaffRoles: miscStaffRoles ?? [])
        }
    }
}

extension Artist {
    init?(data: Data) {
        guard let htmlString = String(data: data, encoding: String.Encoding.utf8),
              let html = try? Kanna.HTML(html: htmlString, encoding: String.Encoding.utf8) else {
            return nil
        }

        let builder = Builder()
        builder.artistName = html.at_css("h1")?.text

        for div in html.css("div") {
            if let divId = div["id"] {
                switch divId {
                case "member_info": Self.parseMemberInfo(from: div, builder: builder)
                case "auditTrail": builder.modificationInfo = ModificationInfo(element: div)
                case "artist_tab_active": Self.parseRoles(from: div, builder: builder, type: .active)
                case "artist_tab_past": Self.parseRoles(from: div, builder: builder, type: .past)
                case "artist_tab_live": Self.parseRoles(from: div, builder: builder, type: .live)
                case "artist_tab_guest": Self.parseRoles(from: div, builder: builder, type: .guestSession)
                case "artist_tab_misc": Self.parseRoles(from: div, builder: builder, type: .misc)
                default: break
                }
            } else if let divClass = div["class"] {
                switch divClass {
                case "member_img": builder.photoUrlString = div.at_css("a")?["href"]
                case "clear band_comment": Self.parseBioAndTrivia(from: div, builder: builder)
                default: break
                }
            }
        }

        guard let artist = builder.build() else { return nil }
        self = artist
    }

    private static func parseMemberInfo(from div: XMLElement, builder: Builder) {
        var infoTypes = [Artist.InfoType]()

        for dt in div.css("dt") {
            if let dtText = dt.text, let type = InfoType(string: dtText) {
                infoTypes.append(type)
            }
        }

        for (index, dd) in div.css("dd").enumerated() {
            guard let ddText = dd.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                continue
            }

            switch infoTypes[index] {
            case .realFullName: builder.realFullName = ddText
            case .age: builder.age = ddText
            case .rip: builder.rip = ddText
            case .causeOfDeath: builder.causeOfDeath = ddText
            case .placeOfOrigin: builder.origin = ddText
            case .gender: builder.gender = ddText
            }
        }
    }

    private static func parseBioAndTrivia(from div: XMLElement, builder: Builder) {
        builder.hasMoreBiography = div.text?.contains("Read more") == true
        guard let innerHtmlString = div.innerHTML else { return }
        let trailingString = builder.hasMoreBiography ?
            #"<h2 class="title_comment">Trivia</h2>"# : #"<div class="tool_strip bottom right">"#
        builder.biographyHtmlString = innerHtmlString
            .subString(after: #"<h2 class="title_comment">Biography</h2>"#, before: trailingString)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        builder.triviaHtmlString = innerHtmlString
            .subString(after: #"<h2 class="title_comment">Trivia</h2>"#)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func parseRoles(from div: XMLElement, builder: Builder, type: RoleType) {
        var roles = [RoleInBand]()

        for memberInBandDiv in div.css("div") where memberInBandDiv["class"] == "member_in_band" {
            let roleInBandBuilder = RoleInBand.Builder()
            var rolesInRelease = [RoleInRelease]()

            if let h3 = memberInBandDiv.at_css("h3") {
                if let a = h3.at_css("a"), let bandName = a.text,
                   let bandUrlString = a["href"]?.components(separatedBy: "#").first {
                    roleInBandBuilder.band = .init(urlString: bandUrlString, name: bandName)
                } else if let bandName = h3.text {
                    // In case the band is not listed on Metal Archives
                    // See more: https://www.metal-archives.com/artists/Rick_Rozz/11902
                    roleInBandBuilder.band = .init(urlString: nil, name: bandName)
                }
            }

            for tr in memberInBandDiv.css("tr") {
                let roleInReleaseBuilder = RoleInRelease.Builder()

                for (index, td) in tr.css("td").enumerated() {
                    guard let tdText = td.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                        continue
                    }
                    switch index {
                    case 0: roleInReleaseBuilder.year = tdText
                    case 1:
                        if let a = td.at_css("a"), let releaseTitle = a.text,
                           let releaseUrlString = a["href"] {
                            roleInReleaseBuilder.release = .init(urlString: releaseUrlString,
                                                                 title: releaseTitle)
                            roleInReleaseBuilder.releaseAdditionalInfo =
                                tdText.subString(after: "(", before: ")")
                        }
                    case 2: roleInReleaseBuilder.description = tdText
                    default: break
                    }
                }

                if let roleInRelease = roleInReleaseBuilder.build() {
                    rolesInRelease.append(roleInRelease)
                }
            }

            roleInBandBuilder.description =
                memberInBandDiv.at_css("p")?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            roleInBandBuilder.roleInReleases = rolesInRelease
            if let roleInBand = roleInBandBuilder.build() {
                roles.append(roleInBand)
            }
        }

        switch type {
        case .active: builder.activeRoles = roles
        case .past: builder.pastRoles = roles
        case .live: builder.liveRoles = roles
        case .guestSession: builder.guestSessionRoles = roles
        case .misc: builder.miscStaffRoles = roles
        }
    }
}
