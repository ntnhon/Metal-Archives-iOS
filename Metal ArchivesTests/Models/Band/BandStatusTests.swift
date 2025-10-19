//
//  BandStatusTests.swift
//  Metal ArchivesTests
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

@testable import Metal_Archives
import XCTest

final class BandStatusTests: XCTestCase {
    func testStatusActive() {
        for item in ["Active", "active", "aCtive", "actiVE"] {
            let sut = BandStatus(rawValue: item)
            XCTAssertEqual(sut, .active)
            XCTAssertEqual(sut.rawValue, "Active")
        }
    }

    func testStatusOnHold() {
        for item in ["on hold", "On Hold", "on Hold", "On hold", "on hOlD"] {
            let sut = BandStatus(rawValue: item)
            XCTAssertEqual(sut, .onHold)
            XCTAssertEqual(sut.rawValue, "On hold")
        }
    }

    func testStatusSplitUp() {
        for item in ["Split-up", "split-up", "spliT-Up", "Split up", "split UP"] {
            let sut = BandStatus(rawValue: item)
            XCTAssertEqual(sut, .splitUp)
            XCTAssertEqual(sut.rawValue, "Split up")
        }
    }

    func testStatusChangedName() {
        for item in ["Changed name", "changed name", "cHanged name", "changed Name"] {
            let sut = BandStatus(rawValue: item)
            XCTAssertEqual(sut, .changedName)
            XCTAssertEqual(sut.rawValue, "Changed name")
        }
    }

    func testStatusDisputed() {
        for item in ["Disputed", "disputed", "dISputed"] {
            let sut = BandStatus(rawValue: item)
            XCTAssertEqual(sut, .disputed)
            XCTAssertEqual(sut.rawValue, "Disputed")
        }
    }

    func testStatusUnknown() {
        for item in ["Unknown", "unknown", "uKNown", "unknowN", "", "ssqcfe"] {
            let sut = BandStatus(rawValue: item)
            XCTAssertEqual(sut, .unknown)
            XCTAssertEqual(sut.rawValue, "Unknown")
        }
    }
}
