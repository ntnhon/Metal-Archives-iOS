//
//  RelatedLinksTests.swift
//  Metal ArchivesTests
//
//  Created by Thanh-Nhon Nguyen on 23/05/2021.
//

@testable import Metal_Archives
import XCTest

class RelatedLinksTests: XCTestCase {
    func testEmptyRelatedLinks() throws {
        // given
        let data = try XCTUnwrap(Data.fromHtml(fileName: "RelatedLinksEmpty"))

        // when
        let sut = [RelatedLink](data: data)

        // then
        XCTAssertTrue(sut.isEmpty)
    }

    func testPublicRelatedLinks() throws {
        // given
        let data = try XCTUnwrap(Data.fromHtml(fileName: "RelatedLinksPublic"))

        // when
        let sut = [RelatedLink](data: data)

        // then
        try testNonEmptySut(sut)
    }

    func testLoggedInSimilarBands() throws {
        // given
        let data = try XCTUnwrap(Data.fromHtml(fileName: "RelatedLinksLoggedIn"))

        // when
        let sut = [RelatedLink](data: data)

        // then
        try testNonEmptySut(sut)
    }

    func testNonEmptySut(_ sut: [RelatedLink]) throws {
        XCTAssertEqual(sut.count, 36)

        let bandCamp = try XCTUnwrap(sut.first { $0.title == "Bandcamp" })
        XCTAssertEqual(bandCamp.urlString, "https://death.bandcamp.com/")

        let guitareTab = try XCTUnwrap(sut.first { $0.title == "GuitareTab" })
        XCTAssertEqual(guitareTab.urlString, "http://www.guitaretab.com/d/death/")
    }
}
