//
//  BandLite.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 30/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class BandLite: ThumbnailableObject {
    let name: String
    
    init?(name: String, urlString: String) {
        self.name = name
        super.init(urlString: urlString, imageType: .bandLogo)
    }
    
    //Sample string: <a href="https://www.metal-archives.com/bands/Meshuggah/21">Meshuggah</a>
    init?(from string: String) {
        guard let urlSubstring = string.subString(after: #"href=""#, before: #"">"#, options: .caseInsensitive),
            let nameSubstring = string.subString(after: #"">"#, before: "</a>", options: .caseInsensitive) else {
                return nil
        }
        
        self.name = String(nameSubstring)
        super.init(urlString: String(urlSubstring), imageType: .bandLogo)
    }
}
