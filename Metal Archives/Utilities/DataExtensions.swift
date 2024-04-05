//
//  DataExtensions.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 26/06/2021.
//

import Foundation

extension Data {
    static func from(fileName: String, extension: String) throws -> Data? {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: `extension`) else {
            return nil
        }
        return try Data(contentsOf: url)
    }

    static func fromJson(fileName: String) throws -> Data? {
        try Data.from(fileName: fileName, extension: "json")
    }

    static func fromHtml(fileName: String) throws -> Data? {
        try Data.from(fileName: fileName, extension: "html")
    }
}
