//
//  Stats.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 23/10/2022.
//

import Foundation
import Kanna
import RegexBuilder

@available(iOS 16, *)
struct Stats {
    let timestamp: String
    let bandStats: BandStats
    let reviewStats: ReviewStats
    let labelStats: LabelStats
    let artistStats: ArtistStats
    let memberStats: MemberStats
    let releaseStats: ReleaseStats
}

struct BandStats {
    let total: Int
    let active: Int
    let onHold: Int
    let splitUp: Int
    let changedName: Int
    let unknown: Int

    static var empty: Self {
        .init(total: 0, active: 0, onHold: 0, splitUp: 0, changedName: 0, unknown: 0)
    }
}

struct ReviewStats {
    let total: Int
    let uniqueAlbums: Int

    static var empty: Self { .init(total: 0, uniqueAlbums: 0) }
}

struct LabelStats {
    let total: Int
    let active: Int
    let closed: Int
    let changedName: Int
    let unknown: Int

    static var empty: Self { .init(total: 0, active: 0, closed: 0, changedName: 0, unknown: 0) }
}

struct ArtistStats {
    let total: Int
    let stillPlaying: Int
    let quitPlaying: Int
    let deceased: Int
    let female: Int
    let male: Int
    let nonBinary: Int
    let nonGendered: Int
    let unknown: Int

    static var empty: Self {
        .init(total: 0,
              stillPlaying: 0,
              quitPlaying: 0,
              deceased: 0,
              female: 0,
              male: 0,
              nonBinary: 0,
              nonGendered: 0,
              unknown: 0)
    }
}

struct MemberStats {
    let total: Int
    let active: Int
    let inactive: Int

    static var empty: Self { .init(total: 0, active: 0, inactive: 0) }
}

struct ReleaseStats {
    let albums: Int
    let songs: Int

    static var empty: Self { .init(albums: 0, songs: 0) }
}

// swiftlint:disable multiline_arguments
@available(iOS 16, *)
extension Stats: HTMLParsable {
    init(data: Data) throws {
        let html = try Kanna.HTML(html: data, encoding: .utf8)
        guard let generalDiv = html.css("div").first(where: { $0["id"] == "general" }) else {
            throw MAError.parseFailure("\(Self.self)")
        }

        var timestamp = ""
        var bandStats = BandStats.empty
        var reviewStats = ReviewStats.empty
        var labelStats = LabelStats.empty
        var artistStats = ArtistStats.empty
        var memberStats = MemberStats.empty
        var releaseStats = ReleaseStats.empty

        for (index, pTag) in generalDiv.css("p").enumerated() {
            guard let text = pTag.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { continue }
            switch index {
            case 0: timestamp = text
            case 1: bandStats = try Self.parseBandStats(from: text)
            case 2: reviewStats = try Self.parseReviewStats(from: text)
            case 3: labelStats = try Self.parseLabelStats(from: text)
            case 4: artistStats = try Self.parseArtistStats(from: text)
            case 5: memberStats = try Self.parseMemberStats(from: text)
            case 6: releaseStats = try Self.parseReleaseStats(from: text)
            default: break
            }
        }

        self.timestamp = timestamp
        self.bandStats = bandStats
        self.reviewStats = reviewStats
        self.labelStats = labelStats
        self.artistStats = artistStats
        self.memberStats = memberStats
        self.releaseStats = releaseStats
    }

    private static func parseBandStats(from text: String) throws -> BandStats {
        // swiftlint:disable:next line_length
        // There is a total of 161672 approved bands. 89147 are active, 3588 are on hold, 49673 are split-up, 6636 changed name, and the rest (12601 bands) are unknown.
        let approvedRef = Reference(Int.self)
        let activeRef = Reference(Int.self)
        let onHoldRef = Reference(Int.self)
        let splitUpRef = Reference(Int.self)
        let changedNameRef = Reference(Int.self)
        let unknownRef = Reference(Int.self)
        let regex = Regex {
            "There is a total of "

            TryCapture(as: approvedRef, {
                OneOrMore(.digit)
            }, transform: { match in
                Int(match)
            })

            " approved bands."

            OneOrMore(.any)

            " "

            TryCapture(as: activeRef, {
                OneOrMore(.digit)
            }, transform: { match in
                Int(match)
            })

            " are active, "

            TryCapture(as: onHoldRef, {
                OneOrMore(.digit)
            }, transform: { match in
                Int(match)
            })

            " are on hold, "

            TryCapture(as: splitUpRef, {
                OneOrMore(.digit)
            }, transform: { match in
                Int(match)
            })

            " are split-up, "

            TryCapture(as: changedNameRef, {
                OneOrMore(.digit)
            }, transform: { match in
                Int(match)
            })

            " changed name, and the rest ("

            TryCapture(as: unknownRef, {
                OneOrMore(.digit)
            }, transform: { match in
                Int(match)
            })

            " bands) are unknown."
        }
        if let result = try regex.firstMatch(in: text) {
            return .init(total: result[approvedRef],
                         active: result[activeRef],
                         onHold: result[onHoldRef],
                         splitUp: result[splitUpRef],
                         changedName: result[changedNameRef],
                         unknown: result[unknownRef])
        }
        return .empty
    }

    private static func parseReviewStats(from text: String) throws -> ReviewStats {
        // There is a total of 121123 approved reviews, for 58918 unique albums.
        let totalRef = Reference(Int.self)
        let uniqueAlbumsRef = Reference(Int.self)
        let regex = Regex {
            "There is a total of "

            TryCapture(as: totalRef) {
                OneOrMore(.digit)
            } transform: { match in
                Int(match)
            }

            " approved reviews, for "

            TryCapture(as: uniqueAlbumsRef) {
                OneOrMore(.digit)
            } transform: { match in
                Int(match)
            }

            " unique albums."
        }
        if let result = try regex.firstMatch(in: text) {
            return .init(total: result[totalRef], uniqueAlbums: result[uniqueAlbumsRef])
        }
        return .empty
    }

    private static func parseLabelStats(from text: String) throws -> LabelStats {
        // swiftlint:disable:next line_length
        // There is a total of 42437 labels. 19456 are active, 12965 are closed, 392 changed name, and the rest (9411 labels) are unknown.
        let totalRef = Reference(Int.self)
        let activeRef = Reference(Int.self)
        let closedRef = Reference(Int.self)
        let changedNameRef = Reference(Int.self)
        let unknownRef = Reference(Int.self)
        let regex = Regex {
            "There is a total of "

            TryCapture(as: totalRef) {
                OneOrMore(.digit)
            } transform: { match in
                Int(match)
            }

            " labels. "

            TryCapture(as: activeRef) {
                OneOrMore(.digit)
            } transform: { match in
                Int(match)
            }

            " are active, "

            TryCapture(as: closedRef) {
                OneOrMore(.digit)
            } transform: { match in
                Int(match)
            }

            " are closed, "

            TryCapture(as: changedNameRef) {
                OneOrMore(.digit)
            } transform: { match in
                Int(match)
            }

            " changed name, and the rest ("

            TryCapture(as: unknownRef) {
                OneOrMore(.digit)
            } transform: { match in
                Int(match)
            }

            " labels) are unknown."
        }
        if let result = try regex.firstMatch(in: text) {
            return .init(total: result[totalRef],
                         active: result[activeRef],
                         closed: result[closedRef],
                         changedName: result[changedNameRef],
                         unknown: result[unknownRef])
        }
        return .empty
    }

    private static func parseArtistStats(from text: String) throws -> ArtistStats {
        // swiftlint:disable:next line_length
        // There is a total of 827026 artists. 683782 are still playing. 143244 quit playing music / metal. 7395 are deceased. 58783 are female, 758034 are male, 198 are non-binary, 787 are non-gendered entities (companies, orchestras, etc.), and 9195 are unknown.
        let totalRef = Reference(Int.self)
        let stillPlayingRef = Reference(Int.self)
        let quitPlayingRef = Reference(Int.self)
        let deceasedRef = Reference(Int.self)
        let femaleRef = Reference(Int.self)
        let maleRef = Reference(Int.self)
        let nonBinaryRef = Reference(Int.self)
        let nonGenderedRef = Reference(Int.self)
        let unknownRef = Reference(Int.self)
        let regex = Regex {
            "There is a total of "

            TryCapture(as: totalRef) {
                OneOrMore(.digit)
            } transform: { match in
                Int(match)
            }

            " artists. "

            TryCapture(as: stillPlayingRef) {
                OneOrMore(.digit)
            } transform: { match in
                Int(match)
            }

            " are still playing. "

            TryCapture(as: quitPlayingRef) {
                OneOrMore(.digit)
            } transform: { match in
                Int(match)
            }

            " quit playing music / metal. "

            TryCapture(as: deceasedRef) {
                OneOrMore(.digit)
            } transform: { match in
                Int(match)
            }

            " are deceased. "

            TryCapture(as: femaleRef) {
                OneOrMore(.digit)
            } transform: { match in
                Int(match)
            }

            " are female, "

            TryCapture(as: maleRef) {
                OneOrMore(.digit)
            } transform: { match in
                Int(match)
            }

            " are male, "

            TryCapture(as: nonBinaryRef) {
                OneOrMore(.digit)
            } transform: { match in
                Int(match)
            }

            " are non-binary, "

            TryCapture(as: nonGenderedRef) {
                OneOrMore(.digit)
            } transform: { match in
                Int(match)
            }

            " are non-gendered entities (companies, orchestras, etc.), and "

            TryCapture(as: unknownRef) {
                OneOrMore(.digit)
            } transform: { match in
                Int(match)
            }

            " are unknown."
        }
        if let result = try regex.firstMatch(in: text) {
            return .init(total: result[totalRef],
                         stillPlaying: result[stillPlayingRef],
                         quitPlaying: result[quitPlayingRef],
                         deceased: result[deceasedRef],
                         female: result[femaleRef],
                         male: result[maleRef],
                         nonBinary: result[nonBinaryRef],
                         nonGendered: result[nonGenderedRef],
                         unknown: result[unknownRef])
        }
        return .empty
    }

    private static func parseMemberStats(from text: String) throws -> MemberStats {
        // There are 1188016 active members, 510256 inactive members for a total of 1698272 registered members.
        let activeRef = Reference(Int.self)
        let inactiveRef = Reference(Int.self)
        let totalRef = Reference(Int.self)
        let regex = Regex {
            "There are "

            TryCapture(as: activeRef) {
                OneOrMore(.digit)
            } transform: { match in
                Int(match)
            }

            " active members, "

            TryCapture(as: inactiveRef) {
                OneOrMore(.digit)
            } transform: { match in
                Int(match)
            }

            " inactive members for a total of "

            TryCapture(as: totalRef) {
                OneOrMore(.digit)
            } transform: { match in
                Int(match)
            }

            " registered members."
        }
        if let result = try regex.firstMatch(in: text) {
            return .init(total: result[totalRef], active: result[activeRef], inactive: result[inactiveRef])
        }
        return .empty
    }

    private static func parseReleaseStats(from text: String) throws -> ReleaseStats {
        // There is a total of 499563 albums and 3403178 songs.
        let albumsRef = Reference(Int.self)
        let songsRef = Reference(Int.self)
        let regex = Regex {
            "There is a total of "

            TryCapture(as: albumsRef) {
                OneOrMore(.digit)
            } transform: { match in
                Int(match)
            }

            " albums and "

            TryCapture(as: songsRef) {
                OneOrMore(.digit)
            } transform: { match in
                Int(match)
            }

            " songs."
        }
        if let result = try regex.firstMatch(in: text) {
            return .init(albums: result[albumsRef], songs: result[songsRef])
        }
        return .empty
    }
}
