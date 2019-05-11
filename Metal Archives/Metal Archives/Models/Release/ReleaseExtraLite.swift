//
//  ReleaseExtraLite.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 24/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class ReleaseExtraLite: ThumbnailableObject {
    let name: String
    
    init?(urlString: String, name: String) {
        self.name = name
        super.init(urlString: urlString, imageType: .release)
    }
    
    //Sample string: <a href="https://www.metal-archives.com/albums/Meshuggah/Destroy_Erase_Improve/53">Destroy Erase Improve</a>
    init?(from string: String) {
        guard let urlSubstring = string.subString(after: #"href=""#, before: #"">"#, options: .caseInsensitive),
            let nameSubstring = string.subString(after: #"">"#, before: "</a>", options: .caseInsensitive) else {
                return nil
        }
        
        self.name = String(nameSubstring)
        super.init(urlString: String(urlSubstring), imageType: .release)
    }
}
