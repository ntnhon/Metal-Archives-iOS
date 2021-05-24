//
//  LabelLiteTests.swift
//  Metal ArchivesTests
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

@testable import Metal_Archives
import XCTest

class LabelLiteTests: XCTestCase {
    func testInit() throws {
        // given
        let name = String.random(length: 20)
        let id = Int.randomId()
        let urlString = "https://example.com/\(id)"

        // when
        let thumbnailInfo = try XCTUnwrap(ThumbnailInfo(urlString: urlString, type: .label))
        let sut = LabelLite(thumbnailInfo: thumbnailInfo, name: name)

        // then
        XCTAssertEqual(sut.name, name)
        XCTAssertEqual(sut.thumbnailInfo.id, id)
        XCTAssertEqual(sut.thumbnailInfo.urlString, urlString)
        XCTAssertEqual(sut.thumbnailInfo.type, .label)
    }
}
