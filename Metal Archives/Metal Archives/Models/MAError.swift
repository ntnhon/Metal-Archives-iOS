//
//  MAError.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/06/2021.
//

import Foundation

enum MAError: Error, CustomStringConvertible {
    case badUrlString(String)
    case invalidServerResponse
    case parseFailure(String)
    case requestFailure(Int)
    case other(Error)

    var description: String {
        switch self {
        case .badUrlString(let urlString):
            return "Bad url (\(urlString))"
        case .invalidServerResponse:
            return "Invalid server response"
        case .parseFailure(let description):
            return "Failed to parse \(description)"
        case .requestFailure(let statusCode):
            return "Request failed with status code \(statusCode)"
        case .other(let error):
            return error.localizedDescription
        }
    }
}
