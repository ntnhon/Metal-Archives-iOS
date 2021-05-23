//
//  DiscographyTests.swift
//  Metal ArchivesTests
//
//  Created by Thanh-Nhon Nguyen on 23/05/2021.
//

@testable import Metal_Archives
import XCTest

class DiscographyTests: XCTestCase {
    func testEmptyDiscography() throws {
        // given
        let data = try XCTUnwrap(Data.fromHtml(fileName: "DiscographyEmpty"))

        // when
        let sut = Discography(data: data)

        // then
        XCTAssertTrue(sut.releases.isEmpty)
    }

    func testPublicDisography() throws {
        // given
        let data = try XCTUnwrap(Data.fromHtml(fileName: "DiscographyPublic"))

        // when
        let sut = Discography(data: data)

        // then
        XCTAssertEqual(sut.releases.count, 58)
        testDeathByMetal(try XCTUnwrap(sut.releases.first { $0.title == "Death by Metal" }))
        testSymbolic(try XCTUnwrap(sut.releases.first { $0.title == "Symbolic" }))
        testLiveInCottbus(try XCTUnwrap(sut.releases.first { $0.title == "Live in Cottbus '98" }))
    }

    func testLoggedInDisography() throws {
        // given
        let data = try XCTUnwrap(Data.fromHtml(fileName: "DiscographyLoggedIn"))

        // when
        let sut = Discography(data: data)

        // then
        XCTAssertEqual(sut.releases.count, 58)
        testDeathByMetal(try XCTUnwrap(sut.releases.first { $0.title == "Death by Metal" }))
        testSymbolic(try XCTUnwrap(sut.releases.first { $0.title == "Symbolic" }))
        testLiveInCottbus(try XCTUnwrap(sut.releases.first { $0.title == "Live in Cottbus '98" }))
    }

    // A demo release with all information
    func testDeathByMetal(_ deathByMetal: ReleaseLite) {
        XCTAssertEqual(deathByMetal.urlString,
                       "https://www.metal-archives.com/albums/Death/Death_by_Metal/35807")
        XCTAssertEqual(deathByMetal.title, "Death by Metal")
        XCTAssertEqual(deathByMetal.type, .demo)
        XCTAssertEqual(deathByMetal.year, 1_984)
        XCTAssertEqual(deathByMetal.reviewCount, 3)
        XCTAssertEqual(deathByMetal.rating, 92)
        XCTAssertEqual(deathByMetal.reviewsUrlString,
                       "https://www.metal-archives.com/reviews/Death/Death_by_Metal/35807/")
    }

    // A full-length release with all information
    func testSymbolic(_ symbolic: ReleaseLite) {
        XCTAssertEqual(symbolic.urlString,
                       "https://www.metal-archives.com/albums/Death/Symbolic/616")
        XCTAssertEqual(symbolic.title, "Symbolic")
        XCTAssertEqual(symbolic.type, .fullLength)
        XCTAssertEqual(symbolic.year, 1_995)
        XCTAssertEqual(symbolic.reviewCount, 31)
        XCTAssertEqual(symbolic.rating, 93)
        XCTAssertEqual(symbolic.reviewsUrlString,
                       "https://www.metal-archives.com/reviews/Death/Symbolic/616/")
    }

    // A video release without review
    func testLiveInCottbus(_ liveInCottbus: ReleaseLite) {
        XCTAssertEqual(liveInCottbus.urlString,
                       "https://www.metal-archives.com/albums/Death/Live_in_Cottbus_%2798/151800")
        XCTAssertEqual(liveInCottbus.title, "Live in Cottbus '98")
        XCTAssertEqual(liveInCottbus.type, .video)
        XCTAssertEqual(liveInCottbus.year, 2_005)
        XCTAssertNil(liveInCottbus.reviewCount)
        XCTAssertNil(liveInCottbus.rating)
        XCTAssertNil(liveInCottbus.reviewsUrlString)
    }
}
