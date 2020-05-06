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
        /// HTML syntax is not appropriate
        case badStructure(anyObject: Any)

        var localizedDescription: String {
            switch self {
            case .badJsonSyntax(let actualSyntax, let expectedSyntax):
                return """
                Bad JSON syntax: \(actualSyntax.self)
                Expected syntax: \(expectedSyntax.self)
                """
    
            case .badStructure(let anyObject):
                return "Error parsing \(anyObject.self)"
            }
        }
    }
}
