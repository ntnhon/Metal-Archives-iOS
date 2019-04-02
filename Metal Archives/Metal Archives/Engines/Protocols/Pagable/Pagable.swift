//
//  Pagable.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 23/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

protocol Pagable {
    static var rawRequestURLString: String { get }
    static var displayLenght: Int { get }
    static func requestURLString(forPage page: Int, withOptions options: [String: String]?) -> String
    static func parseListFrom(data: Data) -> (objects: [Self]?, totalRecords: Int?)?
}

extension Pagable {
    static func requestURLString(forPage page: Int, withOptions options: [String: String]?) -> String {
        var requestURLString = self.rawRequestURLString
        let displayStart = page * self.displayLenght
        
        requestURLString = requestURLString.replacingOccurrences(of: "<DISPLAY_START>", with: "\(displayStart)")
        
        options?.forEach({ (arg) in
            let (key, value) = arg
            requestURLString = requestURLString.replacingOccurrences(of: key, with: value)
        })
        
        guard let formattedRequestURLString = requestURLString.addingPercentEncoding(withAllowedCharacters: customURLQueryAllowedCharacterSet) else {
            fatalError("Error adding percent encoding to requestURLString.")
        }
        
        return formattedRequestURLString
    }
}
