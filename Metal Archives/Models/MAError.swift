//
//  MAError.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/06/2021.
//

import Foundation

enum MAError: Error, CustomStringConvertible {
    case badUrlString(String)
    case failedToUtf8DecodeString
    case failedToFetchLyric(lyricId: String)
    case invalidServerResponse
    case missingBand
    case parseFailure(String)
    case requestFailure(Int)
    case other(Error)
    case songHasNoLyric(title: String)

    var description: String {
        switch self {
        case let .badUrlString(urlString):
            return "Bad url (\(urlString))"
        case .failedToUtf8DecodeString:
            return "Failed to UTF8 decode"
        case let .failedToFetchLyric(lyricId):
            return "Failed to fetch lyric \(lyricId)"
        case .invalidServerResponse:
            return "Invalid server response"
        case .missingBand:
            return "Band is null"
        case let .parseFailure(description):
            return "Failed to parse \(description)"
        case let .requestFailure(statusCode):
            return "Request failed with status code \(statusCode)"
        case let .other(error):
            return error.localizedDescription
        case let .songHasNoLyric(title):
            return "\"\(title)\" has no lyric"
        }
    }
}
