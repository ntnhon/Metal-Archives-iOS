//
//  UserSimpleSearchResult.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 16/11/2022.
//

import Kanna

struct UserSimpleSearchResult {
    let user: UserLite
    let rank: UserRank
    let point: String
}

extension UserSimpleSearchResult: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.hashValue == rhs.hashValue }
}

extension UserSimpleSearchResult: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(user)
        hasher.combine(point)
    }
}

extension UserSimpleSearchResult: PageElement {
    /*
     "<a href=\"https://www.metal-archives.com/users/Hell\" class=\"profileMenu\">Hell</a>",
     "Metal newbie",
     "6"
     */
    init(from strings: [String]) throws {
        guard strings.count == 3 else {
            throw PageElementError.badCount(count: strings.count, expectedCount: 3)
        }

        guard let aTag = try Kanna.HTML(html: strings[0], encoding: .utf8).at_css("a"),
              let name = aTag.text,
              let urlString = aTag["href"]
        else {
            throw PageElementError.failedToParse("\(UserLite.self): \(strings[0])")
        }
        user = .init(name: name, urlString: urlString)
        rank = .init(title: strings[1])
        point = strings[2]
    }
}

final class UserSimpleSearchResultPageManager: PageManager<UserSimpleSearchResult> {
    init(query: String) {
        // swiftlint:disable:next line_length
        let configs = PageConfigs(baseUrlString: "https://www.metal-archives.com/search/ajax-user-search/?field=name&query=\(query)&sEcho=1&iColumns=3&sColumns=&iDisplayStart=\(kDisplayStartPlaceholder)&iDisplayLength=\(kDisplayLengthPlaceholder)&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2",
                                  pageSize: 200)
        super.init(configs: configs)
    }
}
