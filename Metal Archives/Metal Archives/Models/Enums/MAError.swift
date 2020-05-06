//
//  MAError.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 23/04/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

enum MAError: Error, LocalizedError {
    case networking(error: NetworkingError)
    case login(error: LoginError)
    case parsing(error: ParsingError)
    case unknownErrorWithStatusCode(statusCode: Int)
    case unknown(description: String)
    
    var localizedDescription: String {
        switch self {
        case .networking(let error): return error.localizedDescription
        case .login(let error): return error.localizedDescription
        case .parsing(let error): return error.localizedDescription
        case .unknownErrorWithStatusCode(let statusCode): return "Unknown error with status code \(statusCode)"
        case .unknown(let description): return "Unknown error: \(description)"
        }
    }
    
    enum NetworkingError: LocalizedError {
        /// Error creating an URL to make a request
        case badURL(_ urlString: String)
        /// Error parsing response from an URL
        case badResponse(_ response: Any)
        /// Failed to fetch an object
        case failedToFetch(anyObject: Any, error: Error)
        /// Unknown status code
        case unknownStatusCode
        
        var localizedDescription: String {
            switch self {
            case .badURL(let urlString):
                return "Bad URL: \(urlString)"
                
            case .badResponse(let response):
                return "Bad response: \(response)"
                
            case .failedToFetch(let anyObject, let error):
                return "Failed to fetch \(anyObject.self): \(error.localizedDescription)"
                
            case .unknownStatusCode:
                return "Unknown status code"
            }
        }
    }
    
    enum LoginError: LocalizedError {
        /// Incorrect username or password
        case incorrectCredential
        /// Empty response
        case emptyResponse
        /// Failed to parse MyProfile
        case failedToParseMyProfile
        /// Invalid request URL
        case invalidRequestURL(requestURL: String)
        
        var localizedDescription: String {
            switch self {
            case .incorrectCredential: return "Incorrect username or password"
            case .emptyResponse: return "Empty response"
            case .failedToParseMyProfile: return "Failed to parse profile"
            case .invalidRequestURL(let requestURL): return "Invalid request URL: \(requestURL)"
            }
        }
    }
    
    enum ParsingError: LocalizedError {
        /// Bad JSON syntax
        case badJsonSyntax(actualSyntax: Any, expectedSyntax: Any)
        /// Error while extracting useful informations using regular expresion or string manipulation.
        case badSyntax(string: String, expectedSyntax: String)
        /// Error converting extracted informations to a strong type
        case badType(actualType: Any, expectedType: Any)
        /// HTML syntax is not appropriate
        case badStructure(anyObject: Any)

        var localizedDescription: String {
            switch self {
            case .badJsonSyntax(let actualSyntax, let expectedSyntax):
                return """
                Bad JSON syntax: \(actualSyntax.self)
                Expected syntax: \(expectedSyntax.self)
                """
                
            case .badSyntax(let string, let expectedSyntax):
                return """
                Bad syntax: \(string)
                Expected syntax: \(expectedSyntax.self)
                """
                
            case .badType(let actualType, let expectedType):
                return """
                Bad type: \(actualType.self)
                Expected type: \(expectedType.self)
                """
                
            case .badStructure(let anyObject):
                return "Error parsing \(anyObject.self)"
            }
        }
    }
}

enum MAParsingError: LocalizedError {
    /// Error while extracting useful informations using regular expresion or string manipulation.
    case badSyntax(string: String, expectedSyntax: String)
    /// Error converting extracted informations to a strong type
    case badType(string: String, expectedType: String)
    /// HTML syntax is not appropriate
    case badStructure(objectType: String)
    /// Invalid request URL
    case invalidRequestURL(requestURL: String)
    /// Unknown error
    case unknown(description: String)

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
        case .badStructure(let objectType): return "[MAParsingError] Error parsing \(objectType) - Bad HTML structure"
        case .invalidRequestURL(let requestURL): return "Invalid request URL: \(requestURL)"
        case .unknown(let description): return "[MAParsingError] Unknown error: \(description)"
        }
    }
}

enum MAFetchingError: LocalizedError {
    /// Invalid request URL
    case invalidRequestURL(requestURL: String)
    case failedToFetch(object: String)
    
    var localizedDescription: String {
        switch self {
        case .invalidRequestURL(let requestURL): return "Invalid request URL: \(requestURL)"
        case .failedToFetch(let object): return "[MAFetchingError] Failed to fetch \(object)"
        }
    }
}

enum MANetworkingError: LocalizedError {
    /// Error creating an URL to make a request
    case badURL(_ urlString: String)
    /// Error parsing response from an URL
    case badResponse(_ response: Any)
    /// Invalid request URL
    case invalidRequestURL(requestURL: String)
    
    var localizedDescription: String {
        switch self {
        case .badURL(let urlString): return "[MA Networking Error] Bad URL: \(urlString)"
        case .invalidRequestURL(let requestURL): return "Invalid request URL: \(requestURL)"
        case .badResponse(let response): return "[MA Networking Error] Bad response: \(response)"
        }
    }
}
