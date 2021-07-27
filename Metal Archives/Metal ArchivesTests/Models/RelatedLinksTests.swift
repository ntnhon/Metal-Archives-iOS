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
        let sut = RelatedLinkArray(data: data)

        // then
        XCTAssertTrue(sut.content.isEmpty)
    }

    func testPublicRelatedLinks() throws {
        // given
        let data = try XCTUnwrap(Data.fromHtml(fileName: "RelatedLinksPublic"))

        // when
        let sut = RelatedLinkArray(data: data)

        // then
        try testNonEmptySut(sut.content)
    }

    func testLoggedInSimilarBands() throws {
        // given
        let data = try XCTUnwrap(Data.fromHtml(fileName: "RelatedLinksLoggedIn"))

        // when
        let sut = RelatedLinkArray(data: data)

        // then
        try testNonEmptySut(sut.content)
    }

    func testNonEmptySut(_ sut: [RelatedLink]) throws {
        XCTAssertEqual(sut.count, 36)

        let bandCamp = try XCTUnwrap(sut.first { $0.title == "Bandcamp" })
        XCTAssertEqual(bandCamp.urlString, "https://death.bandcamp.com/")

        let guitareTab = try XCTUnwrap(sut.first { $0.title == "GuitareTab" })
        XCTAssertEqual(guitareTab.urlString, "http://www.guitaretab.com/d/death/")
    }
}
