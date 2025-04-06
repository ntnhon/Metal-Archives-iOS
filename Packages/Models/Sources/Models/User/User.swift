//
//  User.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 06/11/2022.
//

import Foundation

public struct User: Sendable, Hashable {
    public let id: String
    public let username: String
    public let rank: UserRank
    public let points: String
    public let fullName: String?
    public let gender: String
    public let age: String
    public let country: Country
    public let homepage: RelatedLink?
    public let favoriteGenres: String?
    public let comments: String?

    public init(id: String,
                username: String,
                rank: UserRank,
                points: String,
                fullName: String?,
                gender: String,
                age: String,
                country: Country,
                homepage: RelatedLink?,
                favoriteGenres: String?,
                comments: String?)
    {
        self.id = id
        self.username = username
        self.rank = rank
        self.points = points
        self.fullName = fullName
        self.gender = gender
        self.age = age
        self.country = country
        self.homepage = homepage
        self.favoriteGenres = favoriteGenres
        self.comments = comments
    }
}

public enum UserRank: Sendable, Hashable {
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

    public var title: String {
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
}
