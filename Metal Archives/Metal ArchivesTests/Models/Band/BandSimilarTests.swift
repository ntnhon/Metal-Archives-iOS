//
//  SimilarBandsTests.swift
//  Metal ArchivesTests
//
//  Created by Thanh-Nhon Nguyen on 23/05/2021.
//

@testable import Metal_Archives
import XCTest

class SimilarBandsTests: XCTestCase {
    func testEmptySimilarBands() throws {
        // given
        let data = try XCTUnwrap(Data.fromHtml(fileName: "BandSimilarsEmpty"))

        // when
        let sut = [BandSimilar](data: data)

        // then
        XCTAssertTrue(sut.isEmpty)
    }

    func testPublicSimilarBands() throws {
        // given
        let data = try XCTUnwrap(Data.fromHtml(fileName: "BandSimilarsPublic"))

        // when
        let sut = [BandSimilar](data: data)

        // then
        try testNonEmptySut(sut)
    }

    func testLoggedInSimilarBands() throws {
        // given
        let data = try XCTUnwrap(Data.fromHtml(fileName: "BandSimilarsLoggedIn"))

        // when
        let sut = [BandSimilar](data: data)

        // then
        try testNonEmptySut(sut)
    }

    func testNonEmptySut(_ sut: [BandSimilar]) throws {
        XCTAssertEqual(sut.count, 308)
        try testAtheist(try XCTUnwrap(sut.first { $0.name == "Atheist" }))
        try testPestilence(try XCTUnwrap(sut.first { $0.name == "Pestilence" }))
    }

    func testAtheist(_ atheist: BandSimilar) throws {
        let us = try XCTUnwrap(CountryManager.shared.country(by: \.isoCode, value: "US"))
        XCTAssertEqual(atheist.urlString,
                       "https://www.metal-archives.com/bands/Atheist/304")
        XCTAssertEqual(atheist.name, "Atheist")
        XCTAssertEqual(atheist.country, us)
        XCTAssertEqual(atheist.genre, "Progressive Death/Thrash Metal with Jazz influences")
        XCTAssertEqual(atheist.score, 389)
    }

    func testPestilence(_ pestilence: BandSimilar) throws {
        let netherlands = try XCTUnwrap(CountryManager.shared.country(by: \.isoCode, value: "NL"))
        XCTAssertEqual(pestilence.urlString,
                       "https://www.metal-archives.com/bands/Pestilence/238")
        XCTAssertEqual(pestilence.name, "Pestilence")
        XCTAssertEqual(pestilence.country, netherlands)
        XCTAssertEqual(pestilence.genre,
                       // swiftlint:disable:next line_length
                       "Thrash Metal (1986-1988); Death Metal (1989-1991, 2008-); Progressive Death Metal/Jazz Fusion (1993)")
        XCTAssertEqual(pestilence.score, 304)
    }
}
