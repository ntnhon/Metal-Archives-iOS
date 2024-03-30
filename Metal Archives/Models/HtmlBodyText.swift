//
//  HtmlBodyText.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/07/2021.
//

import Foundation
import Kanna

struct HtmlBodyText: HTMLParsable {
    let content: String?

    init(data: Data) {
        if let htmlString = String(data: data, encoding: .utf8),
           let doc = try? Kanna.HTML(html: htmlString, encoding: .utf8),
           let bodyText = doc.css("html").first?.at_css("body")?.text {
            content = bodyText
        } else {
            content = nil
        }
    }
}
