//
//  SimpleSearchResultUser.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 16/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class SimpleSearchResultUser {
    let username: String
    let urlString: String
    let rank: String
    let points: String
    
    /*
     Sample array:
     "<a href="https://www.metal-archives.com/users/Hell" class="profileMenu">Hell</a>",
     "Metal newbie",
     "6"
     */

    init?(from array: [String]) {
        guard array.count == 3 else { return nil }
        
        guard let urlSubstring = array[0].subString(after: "href=\"", before: "\" class", options: .caseInsensitive), let usernameSubstring = array[0].subString(after: "profileMenu\">", before: "</a>", options: .caseInsensitive) else { return nil }
        
        self.username = String(usernameSubstring)
        self.urlString = String(urlSubstring)
        self.rank = array[1]
        self.points = array[2]
    }
}

extension SimpleSearchResultUser: Pagable {
    static var rawRequestURLString = "https://www.metal-archives.com/search/ajax-user-search/?field=name&query=<QUERY>&sEcho=1&iColumns=3&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=<DISPLAY_LENGTH>&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2"
    
    static var displayLenght = 200
    
    static func parseListFrom(data: Data) -> (objects: [SimpleSearchResultUser]?, totalRecords: Int?)? {
        guard let (totalRecords, array) = parseTotalRecordsAndArrayOfRawValues(data) else {
            return nil
        }
        var list: [SimpleSearchResultUser] = []
        
        array.forEach { (simpleSearchResultUserDetails) in
            if let simpleSearchResultUser = SimpleSearchResultUser(from: simpleSearchResultUserDetails) {
                list.append(simpleSearchResultUser)
            }
        }
        
        if list.count == 0 {
            return (nil, nil)
        }
        return (list, totalRecords)
    }
}

//MARK: - Actionable
extension SimpleSearchResultUser: Actionable {
    var actionableElements: [ActionableElement] {
        return [ActionableElement.user(name: username, urlString: urlString)]
    }
}
