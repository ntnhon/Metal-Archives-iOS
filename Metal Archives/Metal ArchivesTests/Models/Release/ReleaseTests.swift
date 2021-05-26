//
//  ReleaseTests.swift
//  Metal ArchivesTests
//
//  Created by Thanh-Nhon Nguyen on 26/05/2021.
//

@testable import Metal_Archives
import XCTest

class ReleaseTests: XCTestCase {
    func testReleaseWithLyricsAndInstrumentalTracks() throws {
        // The Sound of Perseverance
        // https://www.metal-archives.com/albums/Death/The_Sound_of_Perseverance/618

        let sut = try XCTUnwrap(Release(data: Data.fromHtml(fileName: "TheSoundOfPerseverance")))

        XCTAssertEqual(sut.id, "618")
        XCTAssertEqual(sut.urlString, "https://www.metal-archives.com/albums/Death/The_Sound_of_Perseverance/618")
    }
}
