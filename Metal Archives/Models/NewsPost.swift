//
//  NewsPost.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 23/10/2022.
//

import Foundation
import Kanna

private let kNewsPostDateFormatter = DateFormatter(dateFormat: "yyyy-MM-dd HH:mm")

struct NewsPost {
    let title: String
    let date: Date
    let content: String
    let urlString: String
    let author: UserLite

    var dateString: String {
        let formatter = DateFormatter(dateFormat: "yyyy-MM-dd")
        let dateString = formatter.string(from: date)
        let relativeFormatter = RelativeDateTimeFormatter()
        relativeFormatter.dateTimeStyle = .numeric
        relativeFormatter.unitsStyle = .full
        let relativeString = relativeFormatter.string(for: date) ?? ""
        return "\(dateString) (\(relativeString))"
    }
}

extension NewsPost: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.title == rhs.title && lhs.date == rhs.date
    }
}

extension NewsPost: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(date)
    }
}

extension NewsPost {
    final class Builder {
        var title: String?
        var date: Date?
        var content: String?
        var urlString: String?
        var author: UserLite?

        func build() -> NewsPost? {
            guard let title else {
                Logger.log("[Building NewsPost] title can not be nil")
                return nil
            }

            guard let date else {
                Logger.log("[Building NewsPost] date can not be nil")
                return nil
            }

            guard let content else {
                Logger.log("[Building NewsPost] content can not be nil")
                return nil
            }

            guard let urlString else {
                Logger.log("[Building NewsPost] urlString can not be nil")
                return nil
            }

            guard let author else {
                Logger.log("[Building NewsPost] author can not be nil")
                return nil
            }

            return .init(title: title,
                         date: date,
                         content: content,
                         urlString: urlString,
                         author: author)
        }
    }
}

// swiftlint:disable identifier_name
extension NewsPost {
    init?(element: XMLElement) {
        let builder = Builder()

        for span in element.css("span") {
            switch span["class"] {
            case "title":
                builder.title = span.text
            case "date":
                if let dateString = span.text {
                    let formatter = DateFormatter(dateFormat: "yyyy-MM-dd HH:mm")
                    builder.date = formatter.date(from: dateString)
                }
            default:
                break
            }
        }

        for p in element.css("p") {
            switch p["class"] {
            case "body":
                builder.content = p.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            case "signature":
                if let aTag = p.at_css("a"),
                   let username = aTag.text,
                   let urlString = aTag["href"]
                {
                    builder.author = .init(name: username, urlString: urlString)
                }
            default:
                break
            }
        }

        for a in element.css("a") {
            if a["class"] == "iconContainer ui-state-default ui-corner-all",
               let urlString = a["href"]
            {
                builder.urlString = urlString
            }
        }

        if let post = builder.build() {
            self = post
        } else {
            return nil
        }
    }
}

struct NewsPage: HTMLParsable {
    let newsPosts: [NewsPost]

    init(data: Data) throws {
        let html = try Kanna.HTML(html: data, encoding: .utf8)
        var newsPosts = [NewsPost]()
        for div in html.css("div") where div["class"] == "motd" {
            if let news = NewsPost(element: div) {
                newsPosts.append(news)
            }
        }
        self.newsPosts = newsPosts
    }
}

// swiftlint:enable identifier_name
