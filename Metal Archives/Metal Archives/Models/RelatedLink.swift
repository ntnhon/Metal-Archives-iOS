//
//  RelatedLink.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 04/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class RelatedLink {
    let title: String
    let urlString: String
    let favIconURLString: String
    
    init?(title: String, urlString: String) {
        self.title = title
        self.urlString = urlString
        
        if let urlComponents = URLComponents(string: urlString), let scheme = urlComponents.scheme, let host = urlComponents.host {
            self.favIconURLString = "http://www.google.com/s2/favicons?domain=\(scheme)://\(host)"
        } else {
            return nil
        }
    }
}
