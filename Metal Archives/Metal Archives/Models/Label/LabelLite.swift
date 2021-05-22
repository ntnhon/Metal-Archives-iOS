//
//  LabelLite.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

struct LabelLite {
    let id: String?
    let name: String
    let urlString: String?

    init(name: String, urlString: String?) {
        self.id = urlString?.components(separatedBy: "/").last
        self.name = name
        self.urlString = urlString
    }
}
