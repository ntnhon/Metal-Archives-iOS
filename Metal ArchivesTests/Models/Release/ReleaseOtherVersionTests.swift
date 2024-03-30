//
//  ReleaseOtherVersionTests.swift
//  Metal ArchivesTests
//
//  Created by Thanh-Nhon Nguyen on 29/05/2021.
//

@testable import Metal_Archives
import XCTest

/*
 class ReleaseOtherVersionTests: XCTestCase {
     func testInvalidOtherVersions() throws {
         // given
         let data = try XCTUnwrap(Data.fromHtml(fileName: "Dummy"))

         // when
         let sut = [ReleaseOtherVersion](data: data)

         // then
         XCTAssertTrue(sut.isEmpty)
     }

     func testPublicOtherVersions() throws {
         // given
         let data = try XCTUnwrap(Data.fromHtml(fileName: "ReleaseOtherVersionsPublic"))

         // when
         let sut = [ReleaseOtherVersion](data: data)

         // then
         XCTAssertFalse(sut.isEmpty)
         XCTAssertEqual(sut.count, 38)

         let firstRelease = try XCTUnwrap(sut.first)
         XCTAssertEqual(firstRelease.urlString, "https://www.metal-archives.com/albums/Death/Human/606")
         XCTAssertEqual(firstRelease.date, "October 22nd, 1991")
         XCTAssertEqual(firstRelease.additionalDetail, "")
         XCTAssertFalse(firstRelease.isUnofficial)
         XCTAssertEqual(firstRelease.labelName, "Relativity Records")
         XCTAssertEqual(firstRelease.catalogId, "88561-2036-2")
         XCTAssertEqual(firstRelease.format, "CD")
         XCTAssertEqual(firstRelease.description, "")

         let humanSymbolic = try XCTUnwrap(sut[15])
         XCTAssertEqual(humanSymbolic.urlString,
                        "https://www.metal-archives.com/albums/Death/Human_-_Symbolic/446368")
         XCTAssertEqual(humanSymbolic.date, "2002")
         XCTAssertEqual(humanSymbolic.additionalDetail, #"(titled "Human / Symbolic")"#)
         XCTAssertTrue(humanSymbolic.isUnofficial)
         XCTAssertEqual(humanSymbolic.labelName, "Agat Company")
         XCTAssertEqual(humanSymbolic.catalogId, "A-485")
         XCTAssertEqual(humanSymbolic.format, "CD")
         XCTAssertEqual(humanSymbolic.description, "")

         let lastRelease = try XCTUnwrap(sut.last)
         XCTAssertEqual(lastRelease.urlString, "https://www.metal-archives.com/albums/Death/Human/622973")
         XCTAssertEqual(lastRelease.date, "Unknown")
         XCTAssertEqual(lastRelease.additionalDetail, "")
         XCTAssertTrue(lastRelease.isUnofficial)
         XCTAssertEqual(lastRelease.labelName, "Спюрк")
         XCTAssertEqual(lastRelease.catalogId, "962")
         XCTAssertEqual(lastRelease.format, "CD")
         XCTAssertEqual(lastRelease.description, "")
     }

     func testLoggedInReleaseOtherVersions() throws {
         // given
         let data = try XCTUnwrap(Data.fromHtml(fileName: "ReleaseOtherVersionsLoggedIn"))

         // when
         let sut = [ReleaseOtherVersion](data: data)

         // then
         XCTAssertFalse(sut.isEmpty)
         XCTAssertEqual(sut.count, 14)

         let firstRelease = try XCTUnwrap(sut.first)
         XCTAssertEqual(firstRelease.urlString, "https://www.metal-archives.com/albums/Opeth/Watershed/189598")
         XCTAssertEqual(firstRelease.date, "May 30th, 2008")
         XCTAssertEqual(firstRelease.additionalDetail, "")
         XCTAssertFalse(firstRelease.isUnofficial)
         XCTAssertEqual(firstRelease.labelName, "Roadrunner Records")
         XCTAssertEqual(firstRelease.catalogId, "RR 7962-2 / 1686-17936-2")
         XCTAssertEqual(firstRelease.format, "CD")
         XCTAssertEqual(firstRelease.description, "")

         let lastRelease = try XCTUnwrap(sut.last)
         XCTAssertEqual(lastRelease.urlString, "https://www.metal-archives.com/albums/Opeth/Watershed/930492")
         XCTAssertEqual(lastRelease.date, "Unknown")
         XCTAssertEqual(lastRelease.additionalDetail, "")
         XCTAssertFalse(lastRelease.isUnofficial)
         XCTAssertEqual(lastRelease.labelName, "Roadrunner Records")
         XCTAssertEqual(lastRelease.catalogId, "")
         XCTAssertEqual(lastRelease.format, "Digital")
         XCTAssertEqual(lastRelease.description, "Special edition")
     }
 }
 */
