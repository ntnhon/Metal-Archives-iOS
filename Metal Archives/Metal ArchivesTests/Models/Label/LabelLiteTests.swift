//
//  LabelLiteTests.swift
//  Metal ArchivesTests
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

@testable import Metal_Archives
import XCTest

class LabelLiteTests: XCTestCase {
    func testInitWithUrlString() {
        // given
        let name = String.random(length: 20)
        let id = String.randomIdString()
        let urlString = "https://example.com/\(id)"

        // when
        let sut = LabelLite(name: name, urlString: urlString)

        // then
        XCTAssertEqual(sut.id, id)
        XCTAssertEqual(sut.name, name)
        XCTAssertEqual(sut.urlString, urlString)
    }

    func testInitWithoutUrlString() {
        // given
        let name = String.random(length: 20)

        // when
        let sut = LabelLite(name: name, urlString: nil)

        // then
        XCTAssertEqual(sut.name, name)
        XCTAssertNil(sut.id)
        XCTAssertNil(sut.urlString)
    }
}
