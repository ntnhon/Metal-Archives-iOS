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
        case .badUrlString(let urlString):
            return "Bad url (\(urlString))"
        case .failedToUtf8DecodeString:
            return "Failed to UTF8 decode"
        case .failedToFetchLyric(let lyricId):
            return "Failed to fetch lyric \(lyricId)"
        case .invalidServerResponse:
            return "Invalid server response"
        case .missingBand:
            return "Band is null"
        case .parseFailure(let description):
            return "Failed to parse \(description)"
        case .requestFailure(let statusCode):
            return "Request failed with status code \(statusCode)"
        case .other(let error):
            return error.localizedDescription
        case .songHasNoLyric(let title):
            return "\"\(title)\" has no lyric"
        }
    }
}
