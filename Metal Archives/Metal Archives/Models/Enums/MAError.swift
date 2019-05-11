//
//  MAError.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 23/04/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

enum MAParsingError: LocalizedError {
    /// Error while extracting useful informations using regular expresion or string manipulation.
    case badSyntax(string: String, expectedSyntax: String)
    /// Error converting extracted informations to a strong type
    case badType(string: String, expectedType: String)

    var localizedDescription: String {
        switch self {
        case .badSyntax(let string, let expectedSyntax): return """
            [MA Parsing Error] Bad syntax for string: \(string).
            Expected syntax: \(expectedSyntax)
            """
        case .badType(let string, let expectedType): return """
            [MA Parsing Error] Error converting - Bad type for string: \(string)
            Expected type: \(expectedType)
            """
        }
    }
}

enum MANetworkingError: LocalizedError {
    /// Error creating an URL to make a request
    case badURL(_ urlString: String)
    /// Error parsing response from an URL
    case badResponse(_ response: Any)
    
    var localizedDescription: String {
        switch self {
        case .badURL(let urlString): return "[MA Networking Error] Bad URL: \(urlString)"
        case .badResponse(let response): return "[MA Networking Error] Bad response: \(response)"
        }
    }
}