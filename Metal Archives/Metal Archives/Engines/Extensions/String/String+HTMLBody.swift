//
//  String+HTMLBody.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 06/05/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import Kanna

extension String {
    static func htmlBodyString(data: Data) -> String? {
        guard let htmlString = String(data: data, encoding: String.Encoding.utf8) else {
            return nil
        }
        
        if let doc = try? Kanna.HTML(html: htmlString, encoding: String.Encoding.utf8),
            let bodyText = doc.css("html").first?.at_css("body")?.text {
            return bodyText
        }
        
        return nil
    }
}
