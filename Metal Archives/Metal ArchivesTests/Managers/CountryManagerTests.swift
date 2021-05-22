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
        XCTAssertTrue(sut.countries.count == 149, "There should be 149 countries")
    }

    func testGetCountryByIsoCode() {
        XCTAssertNil(sut.country(by: \.isoCode, value: "II"), "There is no country with such code II")
        XCTAssertNotNil(sut.country(by: \.isoCode, value: "VN"), "Vietnam is supported")
    }

    func testGetCountryByEmoji() {
        XCTAssertNil(sut.country(by: \.emoji, value: "👽"), "There is no country with such flag 👽")
        XCTAssertNotNil(sut.country(by: \.emoji, value: "🇫🇷"), "France is supported")
    }

    func testGetCountryByName() {
        XCTAssertNil(sut.country(by: \.name, value: "Doge"), "There is no country with such name Doge")
        XCTAssertNotNil(sut.country(by: \.name, value: "United Kingdom"), "United Kingdom is supported")
    }
}
