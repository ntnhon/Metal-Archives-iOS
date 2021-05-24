//
//  ArtistLiteTests.swift
//  Metal ArchivesTests
//
//  Created by Thanh-Nhon Nguyen on 24/05/2021.
//

@testable import Metal_Archives
import XCTest

class ArtistLiteTests: XCTestCase {
    func testEmptyThumbnailInfo() {
        // given
        let builder = ArtistLite.Builder()
        builder.thumbnailInfo = nil
        builder.name = String.random(length: 10)
        builder.instruments = String.random(length: 10)
        builder.bands = [BandLite]()
        builder.seeAlso = nil

        // when
        let sut = builder.build()

        // then
        XCTAssertNil(sut)
    }

    func testFalseThumbnailInfo() {
        // given
        let builder = ArtistLite.Builder()
        builder.thumbnailInfo = .random(type: .label)
        builder.name = String.random(length: 10)
        builder.instruments = String.random(length: 10)
        builder.bands = [BandLite]()
        builder.seeAlso = nil

        // when
        let sut = builder.build()

        // then
        XCTAssertNil(sut)
    }

    func testEmptyName() {
        // given
        let builder = ArtistLite.Builder()
        builder.thumbnailInfo = .random(type: .artist)
        builder.name = nil
        builder.instruments = String.random(length: 10)
        builder.bands = [BandLite]()
        builder.seeAlso = String.random(length: 10)

        // when
        let sut = builder.build()

        // then
        XCTAssertNil(sut)
    }

    func testEmptyInstruments() {
        // given
        let builder = ArtistLite.Builder()
        builder.thumbnailInfo = .random(type: .artist)
        builder.name = String.random(length: 10)
        builder.instruments = nil
        builder.bands = [BandLite]()
        builder.seeAlso = String.random(length: 10)

        // when
        let sut = builder.build()

        // then
        XCTAssertNil(sut)
    }

    func testEmptyBands() {
        // given
        let builder = ArtistLite.Builder()
        builder.thumbnailInfo = .random(type: .artist)
        builder.name = String.random(length: 10)
        builder.instruments = String.random(length: 10)
        builder.bands = nil
        builder.seeAlso = String.random(length: 10)

        // when
        let sut = builder.build()

        // then
        XCTAssertNil(sut)
    }

    func testInitSuccess() {
        // given
        let builder = ArtistLite.Builder()
        builder.thumbnailInfo = .random(type: .artist)
        builder.name = String.random(length: 10)
        builder.instruments = String.random(length: 10)
        builder.bands = [BandLite]()
        builder.seeAlso = String.random(length: 10)

        // when
        let sut = builder.build()

        // then
        XCTAssertNotNil(sut)
    }
}
