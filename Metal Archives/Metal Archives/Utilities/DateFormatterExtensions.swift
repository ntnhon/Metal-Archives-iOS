//
//  DateFormatterExtensions.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

import Foundation

extension DateFormatter {
    static let `default` = DateFormatter(dateFormat: "yyyy-MM-dd HH:mm:ss")

    convenience init(dateFormat: String) {
        self.init()
        self.dateFormat = dateFormat
    }
}
