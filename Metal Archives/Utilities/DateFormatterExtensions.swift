//
//  DateFormatterExtensions.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

import Foundation

extension DateFormatter {
    static let `default` = DateFormatter(dateFormat: "yyyy-MM-dd HH:mm:ss")
    static let dateOnly = DateFormatter(dateFormat: "yyyy-MM-dd")

    convenience init(dateFormat: String) {
        self.init()
        self.dateFormat = dateFormat
    }
}

extension RelativeDateTimeFormatter {
    static let `default`: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()
}
