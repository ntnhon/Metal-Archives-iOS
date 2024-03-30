//
//  TopUsers.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 18/10/2022.
//

import Foundation
import Kanna

struct TopUsers {
    let bySubmittedBands: [TopUser]
    let byWrittenReviews: [TopUser]
    let bySubmittedAlbums: [TopUser]
    let byArtistsAdded: [TopUser]
}

struct TopUser {
    let user: UserLite
    let count: Int
}

extension TopUsers: HTMLParsable {
    init(data: Data) throws {
        let html = try Kanna.HTML(html: data, encoding: .utf8)

        var bySubmittedBands = [TopUser]()
        var byWrittenReviews = [TopUser]()
        var bySubmittedAlbums = [TopUser]()
        var byArtistsAdded = [TopUser]()

        let parseTopUsers: (XMLElement?) -> [TopUser] = { element in
            guard let element else { return [] }

            var users = [TopUser]()
            for tr in element.css("tr") {
                var user: UserLite?
                var count: Int?

                for td in tr.css("td") {
                    if let aTag = td.at_css("a"),
                       let username = aTag.text,
                       let urlString = aTag["href"] {
                        user = .init(name: username, urlString: urlString)
                    } else if let text = td.text,
                              !text.contains(".") {
                        count = Int(text)
                    }
                }

                if let user, let count {
                    users.append(.init(user: user, count: count))
                }
            }

            return users
        }

        for div in html.css("div") {
            switch div["id"] {
            case "members_bands":
                bySubmittedBands = parseTopUsers(div)
            case "members_reviews":
                byWrittenReviews = parseTopUsers(div)
            case "members_albums":
                bySubmittedAlbums = parseTopUsers(div)
            case "members_artists":
                byArtistsAdded = parseTopUsers(div)
            default:
                break
            }
        }

        self.bySubmittedBands = bySubmittedBands
        self.byWrittenReviews = byWrittenReviews
        self.bySubmittedAlbums = bySubmittedAlbums
        self.byArtistsAdded = byArtistsAdded
    }
}
