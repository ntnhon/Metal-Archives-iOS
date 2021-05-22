//
//  BandStatusTests.swift
//  Metal ArchivesTests
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

@testable import Metal_Archives
import XCTest

class BandStatusTests: XCTestCase {
    func testStatusActive() {
        ["Active", "active", "aCtive", "actiVE"].forEach {
            let sut = Band.Status(rawValue: $0)
            XCTAssertEqual(sut, .active)
            XCTAssertEqual(sut.rawValue, "Active")
        }
    }

    func testStatusOnHold() {
        ["on hold", "On Hold", "on Hold", "On hold", "on hOlD"].forEach {
            let sut = Band.Status(rawValue: $0)
            XCTAssertEqual(sut, .onHold)
            XCTAssertEqual(sut.rawValue, "On hold")
        }
    }

    func testStatusSplitUp() {
        ["Split-up", "split-up", "spliT-Up", "Split up", "split UP"].forEach {
            let sut = Band.Status(rawValue: $0)
            XCTAssertEqual(sut, .splitUp)
            XCTAssertEqual(sut.rawValue, "Split up")
        }
    }

    func testStatusChangedName() {
        ["Changed name", "changed name", "cHanged name", "changed Name"].forEach {
            let sut = Band.Status(rawValue: $0)
            XCTAssertEqual(sut, .changedName)
            XCTAssertEqual(sut.rawValue, "Changed name")
        }
    }

    func testStatusDisputed() {
        ["Disputed", "disputed", "dISputed"].forEach {
            let sut = Band.Status(rawValue: $0)
            XCTAssertEqual(sut, .disputed)
            XCTAssertEqual(sut.rawValue, "Disputed")
        }
    }

    func testStatusUnknown() {
        ["Unknown", "unknown", "uKNown", "unknowN", "", "ssqcfe"].forEach {
            let sut = Band.Status(rawValue: $0)
            XCTAssertEqual(sut, .unknown)
            XCTAssertEqual(sut.rawValue, "Unknown")
        }
    }
}
