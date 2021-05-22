//
//  CountryManagerTests.swift
//  Metal ArchivesTests
//
//  Created by Thanh-Nhon Nguyen on 21/05/2021.
//

@testable import Metal_Archives
import XCTest

class CountryManagerTests: XCTestCase {
    var sut: CountryManager!

    override func setUp() {
        super.setUp()
        sut = CountryManager.shared
    }

    func testInitSuccess() {
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.countries.count, 149)
    }

    func testGetCountryByIsoCode() throws {
        XCTAssertNil(sut.country(by: \.isoCode, value: "II"))

        let vietnam = try XCTUnwrap(sut.country(by: \.isoCode, value: "VN"))
        XCTAssertEqual(vietnam.isoCode, "VN")
        XCTAssertEqual(vietnam.name, "Vietnam")
        XCTAssertEqual(vietnam.flag, "🇻🇳")
    }

    func testGetCountryByEmoji() throws {
        XCTAssertNil(sut.country(by: \.flag, value: "👽"))

        let france = try XCTUnwrap(sut.country(by: \.flag, value: "🇫🇷"))
        XCTAssertEqual(france.isoCode, "FR")
        XCTAssertEqual(france.name, "France")
        XCTAssertEqual(france.flag, "🇫🇷")
    }

    func testGetCountryByName() throws {
        XCTAssertNil(sut.country(by: \.name, value: "Doge"))

        let uk = try XCTUnwrap(sut.country(by: \.name, value: "United Kingdom"))
        XCTAssertEqual(uk.isoCode, "GB")
        XCTAssertEqual(uk.name, "United Kingdom")
        XCTAssertEqual(uk.flag, "🇬🇧")
    }
}
