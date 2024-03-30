//
//  BandSimilarTests.swift
//  Metal ArchivesTests
//
//  Created by Thanh-Nhon Nguyen on 23/05/2021.
//

// swiftlint:disable line_length
@testable import Metal_Archives
import XCTest

/*
 class SimilarBandsTests: XCTestCase {
     func testInvalidSimilarBands() throws {
         // given
         let data = try XCTUnwrap(Data.fromHtml(fileName: "Dummy"))

         // when
         let sut = BandSimilarArray(data: data)

         // then
         XCTAssertTrue(sut.content.isEmpty)
     }

     func testEmptySimilarBands() throws {
         // given
         let data = try XCTUnwrap(Data.fromHtml(fileName: "BandSimilarsEmpty"))

         // when
         let sut = BandSimilarArray(data: data)

         // then
         XCTAssertTrue(sut.content.isEmpty)
     }

     func testPublicSimilarBands() throws {
         // given
         let data = try XCTUnwrap(Data.fromHtml(fileName: "BandSimilarsPublic"))

         // when
         let sut = BandSimilarArray(data: data)

         // then
         try testNonEmptySut(sut.content)
     }

     func testLoggedInSimilarBands() throws {
         // given
         let data = try XCTUnwrap(Data.fromHtml(fileName: "BandSimilarsLoggedIn"))

         // when
         let sut = BandSimilarArray(data: data)

         // then
         try testNonEmptySut(sut.content)
     }

     func testNonEmptySut(_ sut: [BandSimilar]) throws {
         XCTAssertEqual(sut.count, 308)
         try testAtheist(try XCTUnwrap(sut.first { $0.name == "Atheist" }))
         try testPestilence(try XCTUnwrap(sut.first { $0.name == "Pestilence" }))
     }

     func testAtheist(_ atheist: BandSimilar) throws {
         let us = try XCTUnwrap(CountryManager.shared.country(by: \.isoCode, value: "US"))
         XCTAssertEqual(atheist.thumbnailInfo.id, 304)
         XCTAssertEqual(atheist.thumbnailInfo.urlString,
                        "https://www.metal-archives.com/bands/Atheist/304")
         XCTAssertEqual(atheist.thumbnailInfo.type, .bandLogo)
         XCTAssertEqual(atheist.name, "Atheist")
         XCTAssertEqual(atheist.country, us)
         XCTAssertEqual(atheist.genre, "Progressive Death/Thrash Metal with Jazz influences")
         XCTAssertEqual(atheist.score, 389)
     }

     func testPestilence(_ pestilence: BandSimilar) throws {
         let netherlands = try XCTUnwrap(CountryManager.shared.country(by: \.isoCode, value: "NL"))
         XCTAssertEqual(pestilence.thumbnailInfo.id, 238)
         XCTAssertEqual(pestilence.thumbnailInfo.urlString,
                        "https://www.metal-archives.com/bands/Pestilence/238")
         XCTAssertEqual(pestilence.thumbnailInfo.type, .bandLogo)
         XCTAssertEqual(pestilence.name, "Pestilence")
         XCTAssertEqual(pestilence.country, netherlands)
         XCTAssertEqual(pestilence.genre,
                        "Thrash Metal (1986-1988); Death Metal (1989-1991, 2008-); Progressive Death Metal/Jazz Fusion (1993)")
         XCTAssertEqual(pestilence.score, 304)
     }
 }
 */
// swiftlint:enable line_length
