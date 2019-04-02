//
//  Label.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class LabelLiteInBand {
    let id: String?
    let name: String
    let urlString: String?
    
    init(name: String, urlString: String? = nil) {
        if let `urlString` = urlString {
            //Extract id from URLString
            if let id = urlString.components(separatedBy: "/").last {
                self.id = id
            } else {
                self.id = nil
            }
        } else {
            self.id = nil
        }
        
        self.name = name
        self.urlString = urlString
    }
}
