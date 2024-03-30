//
//  LabelLiteTests.swift
//  Metal ArchivesTests
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

@testable import Metal_Archives
import XCTest

class LabelLiteTests: XCTestCase {
    func testOptional() {
        // given
        let name = String.random(length: 20)
        let urlString = String.random(length: 20)

        // when
        let sut = LabelLite(thumbnailInfo: .init(urlString: urlString, type: .label), name: name)

        // then
        XCTAssertEqual(sut.name, name)
        XCTAssertNil(sut.thumbnailInfo)
    }

    func testNonOptional() throws {
        // given
        let name = String.random(length: 20)
        let id = Int.randomId()
        let urlString = "https://example.com/\(id)"

        // when
        let sut = LabelLite(thumbnailInfo: .init(urlString: urlString, type: .label), name: name)

        // then
        XCTAssertEqual(sut.name, name)
        let thumbnailInfo = try XCTUnwrap(sut.thumbnailInfo)
        XCTAssertEqual(thumbnailInfo.id, id)
        XCTAssertEqual(thumbnailInfo.urlString, urlString)
        XCTAssertEqual(thumbnailInfo.type, .label)
    }
}
