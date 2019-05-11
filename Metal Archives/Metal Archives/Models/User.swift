//
//  User.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 11/05/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

struct User {
    let name: String
    let urlString: String
    
    //Example:
    //"<a href="https://www.metal-archives.com/users/Euthanasiast" class="profileMenu">Euthanasiast</a>"
    init?(from string: String) {
        guard let urlSubstring = string.subString(after: #"href=""#, before: #"" "#, options: .caseInsensitive),
            let nameSubstring = string.subString(after: #"">"#, before: "</a>", options: .caseInsensitive) else {
                return nil
        }
        
        self.name = String(nameSubstring)
        self.urlString = String(urlSubstring)
    }
}
