//
//  NewsPost.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 23/10/2022.
//

import Foundation

public struct NewsPost: Sendable, Hashable {
    public let title: String
    public let date: Date
    public let content: String
    public let urlString: String
    public let author: UserLite

    public var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        let relativeFormatter = RelativeDateTimeFormatter()
        relativeFormatter.dateTimeStyle = .numeric
        relativeFormatter.unitsStyle = .full
        let relativeString = relativeFormatter.string(for: date) ?? ""
        return "\(dateString) (\(relativeString))"
    }
}
