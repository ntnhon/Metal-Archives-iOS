//
//  UserSimpleSearchResult.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 16/11/2022.
//

import Foundation

public struct UserSimpleSearchResult: Sendable, Hashable {
    public let user: UserLite
    public let rank: UserRank
    public let point: String

    public init(user: UserLite, rank: UserRank, point: String) {
        self.user = user
        self.rank = rank
        self.point = point
    }
}
