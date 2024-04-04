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
    case deallocatedSelf

    var description: String {
        switch self {
        case let .badUrlString(urlString):
            "Bad url (\(urlString))"
        case .failedToUtf8DecodeString:
            "Failed to UTF8 decode"
        case let .failedToFetchLyric(lyricId):
            "Failed to fetch lyric \(lyricId)"
        case .invalidServerResponse:
            "Invalid server response"
        case .missingBand:
            "Band is null"
        case let .parseFailure(description):
            "Failed to parse \(description)"
        case let .requestFailure(statusCode):
            "Request failed with status code \(statusCode)"
        case let .other(error):
            error.localizedDescription
        case let .songHasNoLyric(title):
            "\"\(title)\" has no lyric"
        case .deallocatedSelf:
            "Deallocated self"
        }
    }
}
