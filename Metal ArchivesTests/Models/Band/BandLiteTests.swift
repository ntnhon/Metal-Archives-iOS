//
//  BandLiteTests.swift
//  Metal ArchivesTests
//
//  Created by Thanh-Nhon Nguyen on 24/05/2021.
//

@testable import Metal_Archives
import XCTest

final class BandLiteTests: XCTestCase {
    func testInitSuccess() throws {
        // given
        let urlString = "https://www.metal-archives.com/bands/Raw_Dog/3540488927"
        let name = "Raw Dog"

        // when
        let sut = try XCTUnwrap(BandLite(urlString: urlString, name: name))

        // then
        XCTAssertEqual(sut.thumbnailInfo.id, 3_540_488_927)
        XCTAssertEqual(sut.thumbnailInfo.urlString, urlString)
        XCTAssertEqual(sut.thumbnailInfo.type, .bandLogo)
        XCTAssertEqual(sut.name, name)
    }

    func testInitFailure() throws {
        // given
        let urlString = "https://example.com"
        let name = String.random(length: 10)

        // when
        let sut = BandLite(urlString: urlString, name: name)

        // then
        XCTAssertNil(sut)
    }
}
