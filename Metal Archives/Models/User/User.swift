//
//  User.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 06/11/2022.
//

import Foundation
import Kanna
import SwiftUI

struct User {
    let id: String
    let username: String
    let rank: UserRank
    let points: String
    let fullName: String?
    let gender: String
    let age: String
    let country: Country
    let homepage: RelatedLink?
    let favoriteGenres: String?
    let comments: String?
}

extension User {
    private enum InfoType {
        case rank, points, email, fullName, gender, age, country, homepage, genre, comments

        init?(string: String) {
            let lowercasedString = string.lowercased()
            if lowercasedString.contains("rank") {
                self = .rank
            } else if lowercasedString.contains("points") {
                self = .points
            } else if lowercasedString.contains("email") {
                self = .email
            } else if lowercasedString.contains("name") {
                self = .fullName
            } else if lowercasedString.contains("gender") {
                self = .gender
            } else if lowercasedString.contains("homepage") {
                self = .homepage
            } else if lowercasedString.contains("country") {
                self = .country
            } else if lowercasedString.contains("age") {
                self = .age
            } else if lowercasedString.contains("genre") {
                self = .genre
            } else if lowercasedString.contains("comments") {
                self = .comments
            } else {
                return nil
            }
        }
    }
}

enum UserRank {
    case webmaster
    case metalGod
    case metalLord
    case metalDemon
    case metalKnight
    case dishonourablyDischarged
    case metalFreak
    case veteran
    case metalhead
    case other(String)

    var title: String {
        switch self {
        case .webmaster:
            "Webmaster"
        case .metalGod:
            "Metal God"
        case .metalLord:
            "Metal lord"
        case .metalDemon:
            "Metal demon"
        case .metalKnight:
            "Metal knight"
        case .dishonourablyDischarged:
            "Dishonourably Discharged"
        case .metalFreak:
            "Metal freak"
        case .veteran:
            "Veteran"
        case .metalhead:
            "Metalhead"
        case let .other(title):
            title
        }
    }

    var color: Color {
        switch self {
        case .webmaster, .metalGod, .metalLord:
            .red
        case .metalDemon:
            .yellow
        case .metalKnight:
            .green
        case .dishonourablyDischarged:
            .blue
        case .metalFreak:
            .cyan
        case .veteran:
            .purple
        case .metalhead:
            Color(.magenta)
        case .other:
            .primary
        }
    }

    init(title: String) {
        let lowercasedTitle = title.lowercased()
        if lowercasedTitle.contains("webmaster") {
            self = .webmaster
        } else if lowercasedTitle.contains("god") {
            self = .metalGod
        } else if lowercasedTitle.contains("lord") {
            self = .metalLord
        } else if lowercasedTitle.contains("demon") {
            self = .metalDemon
        } else if lowercasedTitle.contains("knight") {
            self = .metalKnight
        } else if lowercasedTitle.contains("discharged") {
            self = .dishonourablyDischarged
        } else if lowercasedTitle.contains("freak") {
            self = .metalFreak
        } else if lowercasedTitle.contains("veteran") {
            self = .veteran
        } else if lowercasedTitle.contains("metalhead") {
            self = .metalhead
        } else {
            self = .other(title)
        }
    }
}

extension User {
    final class Builder {
        var id: String?
        var username: String?
        var rank: UserRank?
        var points: String?
        var fullName: String?
        var gender: String?
        var age: String?
        var country: Country?
        var homepage: RelatedLink?
        var favoriteGenres: String?
        var comments: String?

        func build() -> User? {
            guard let id else {
                Logger.log("[Building User] id can not be nil")
                return nil
            }

            guard let username else {
                Logger.log("[Building User] username can not be nil")
                return nil
            }

            guard let rank else {
                Logger.log("[Building User] rank can not be nil")
                return nil
            }

            guard let points else {
                Logger.log("[Building User] points can not be nil")
                return nil
            }

            guard let gender else {
                Logger.log("[Building User] gender can not be nil")
                return nil
            }

            guard let age else {
                Logger.log("[Building User] age can not be nil")
                return nil
            }

            guard let country else {
                Logger.log("[Building User] country can not be nil")
                return nil
            }

            return .init(id: id,
                         username: username,
                         rank: rank,
                         points: points,
                         fullName: fullName,
                         gender: gender,
                         age: age,
                         country: country,
                         homepage: homepage,
                         favoriteGenres: favoriteGenres,
                         comments: comments)
        }
    }
}

extension User: HTMLParsable {
    init(data: Data) throws {
        let html = try Kanna.HTML(html: data, encoding: .utf8)
        let builder = Builder()

        for h1 in html.css("h1") where h1["class"] == "page_title" {
            builder.username = h1.text?.replacingOccurrences(of: "'s profile", with: "")
        }

        for div in html.css("div") {
            switch div["id"] {
            case "userInfo":
                let aTag = div.css("a").first { $0["href"]?.contains("https://") == true }
                builder.id = aTag?["href"]?.components(separatedBy: "/").last
            case "user_tab_profile":
                Self.parseInfo(from: div, builder: builder)
            default:
                break
            }
        }

        guard let user = builder.build() else {
            throw MAError.parseFailure("\(Self.self)")
        }
        self = user
    }

    private static func parseInfo(from div: XMLElement, builder: Builder) {
        var infoTypes = [User.InfoType]()

        for dt in div.css("dt") {
            if let dtText = dt.text,
               let type = User.InfoType(string: dtText)
            {
                infoTypes.append(type)
            }
        }

        for (index, dd) in div.css("dd").enumerated() {
            guard let ddText = dd.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { continue }
            switch infoTypes[index] {
            case .rank:
                builder.rank = .init(title: ddText)
            case .points:
                builder.points = ddText
            case .email:
                break
            case .fullName:
                builder.fullName = ddText
            case .gender:
                builder.gender = ddText
            case .age:
                builder.age = ddText
            case .country:
                builder.country = CountryManager.shared.country(by: \.name, value: ddText)
            case .homepage:
                if let aTag = dd.at_css("a"),
                   let title = aTag.text,
                   let urlString = aTag["href"]
                {
                    builder.homepage = .init(urlString: urlString, title: title)
                }
            case .genre:
                builder.favoriteGenres = ddText
            case .comments:
                builder.comments = div.at_css("p")?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
    }
}
