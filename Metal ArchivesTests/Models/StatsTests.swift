//
//  StatsTests.swift
//  Metal ArchivesTests
//
//  Created by Nhon Nguyen on 23/10/2022.
//

@testable import Metal_Archives
import XCTest

@available(iOS 16, *)
final class StatsTests: XCTestCase {
    func testParseStats() throws {
        let data: Data = try Data.from(fileName: "Stats", extension: "html")
        let sut = try Stats(data: data)
        XCTAssertEqual(sut.timestamp, "Stats as of October 24th, 2022, 1:34 pm EDT")

        // Band stats
        XCTAssertEqual(sut.bandStats.total, 161_672)
        XCTAssertEqual(sut.bandStats.active, 89147)
        XCTAssertEqual(sut.bandStats.onHold, 3588)
        XCTAssertEqual(sut.bandStats.splitUp, 49673)
        XCTAssertEqual(sut.bandStats.changedName, 6636)
        XCTAssertEqual(sut.bandStats.unknown, 12601)

        // Review stats
        XCTAssertEqual(sut.reviewStats.total, 121_123)
        XCTAssertEqual(sut.reviewStats.uniqueAlbums, 58918)

        // Label stats
        XCTAssertEqual(sut.labelStats.total, 42437)
        XCTAssertEqual(sut.labelStats.active, 19456)
        XCTAssertEqual(sut.labelStats.closed, 12965)
        XCTAssertEqual(sut.labelStats.changedName, 392)
        XCTAssertEqual(sut.labelStats.unknown, 9411)

        // Artist stats
        XCTAssertEqual(sut.artistStats.total, 827_026)
        XCTAssertEqual(sut.artistStats.stillPlaying, 683_782)
        XCTAssertEqual(sut.artistStats.quitPlaying, 143_244)
        XCTAssertEqual(sut.artistStats.deceased, 7395)
        XCTAssertEqual(sut.artistStats.female, 58783)
        XCTAssertEqual(sut.artistStats.male, 758_034)
        XCTAssertEqual(sut.artistStats.nonBinary, 198)
        XCTAssertEqual(sut.artistStats.nonGendered, 787)
        XCTAssertEqual(sut.artistStats.unknown, 9195)

        // Member stats
        XCTAssertEqual(sut.memberStats.active, 1_188_016)
        XCTAssertEqual(sut.memberStats.inactive, 510_256)
        XCTAssertEqual(sut.memberStats.total, 1_698_272)

        // Release stats
        XCTAssertEqual(sut.releaseStats.albums, 499_563)
        XCTAssertEqual(sut.releaseStats.songs, 3_403_178)
    }
}
