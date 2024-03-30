//
//  DataExtensions.swift
//  Metal ArchivesTests
//
//  Created by Thanh-Nhon Nguyen on 23/05/2021.
//

import Foundation
import XCTest

extension Data {
    static func from(fileName: String, extension: String) throws -> Data {
        let bundle = Bundle(for: TestBundleClass.self)
        let url = try XCTUnwrap(bundle.url(forResource: fileName, withExtension: `extension`),
                                "Unable to find \(fileName).\(`extension`) in \(bundle.bundleURL)")
        return try Data(contentsOf: url)
    }

    static func fromJson(fileName: String) throws -> Data {
        try Data.from(fileName: fileName, extension: "json")
    }

    static func fromHtml(fileName: String) throws -> Data {
        try Data.from(fileName: fileName, extension: "html")
    }
}

private class TestBundleClass {}
