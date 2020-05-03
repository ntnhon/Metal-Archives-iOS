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
    static var displayLength: Int { get }
    //init?(from array: [String])
    static func requestURLString(forPage page: Int, withOptions options: [String: String]?) -> String
    static func parseListFrom(data: Data) -> (objects: [Self]?, totalRecords: Int?)?
}

extension Pagable {
    static func requestURLString(forPage page: Int, withOptions options: [String: String]?) -> String {
        var requestURLString = rawRequestURLString
        let displayStart = page * displayLength
        
        requestURLString = requestURLString.replacingOccurrences(of: "<DISPLAY_START>", with: "\(displayStart)")
        requestURLString = requestURLString.replacingOccurrences(of: "<DISPLAY_LENGTH>", with: "\(self.displayLength)")
        
        options?.forEach({ (arg) in
            let (key, value) = arg
            requestURLString = requestURLString.replacingOccurrences(of: key, with: value)
        })
        
        guard let formattedRequestURLString = requestURLString.addingPercentEncoding(withAllowedCharacters: customURLQueryAllowedCharacterSet) else {
            fatalError("Error adding percent encoding to requestURLString.")
        }
        
        return formattedRequestURLString
    }
    
    static func parseTotalRecordsAndArrayOfRawValues(_ data: Data) -> (totalRecords: Int?, [[String]])? {
        guard
            let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String:Any],
            let array = json["aaData"] as? [[String]]
            else {
                return nil
        }
        
        let totalRecords = json["iTotalRecords"] as? Int
        return (totalRecords, array)
    }
}
