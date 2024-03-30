//
//  ReleaseTypeTests.swift
//  Metal ArchivesTests
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

@testable import Metal_Archives
import XCTest

class ReleaseTypeTests: XCTestCase {
    func testTypeFullLength() throws {
        try ["full-length", "Full-Length", "full-Length"].forEach {
            let sut = try XCTUnwrap(ReleaseType(typeString: $0))
            XCTAssertEqual(sut, .fullLength)
            XCTAssertEqual(sut.description, "Full-length")
        }
    }

    func testTypeLiveAlbum() throws {
        try ["Live album", "Live Album", "live album", "live aLbum"].forEach {
            let sut = try XCTUnwrap(ReleaseType(typeString: $0))
            XCTAssertEqual(sut, .liveAlbum)
            XCTAssertEqual(sut.description, "Live album")
        }
    }

    func testTypeDemo() throws {
        try ["Demo", "demo", "dEMo"].forEach {
            let sut = try XCTUnwrap(ReleaseType(typeString: $0))
            XCTAssertEqual(sut, .demo)
            XCTAssertEqual(sut.description, "Demo")
        }
    }

    func testTypeSingle() throws {
        try ["Single", "single", "sIngLE"].forEach {
            let sut = try XCTUnwrap(ReleaseType(typeString: $0))
            XCTAssertEqual(sut, .single)
            XCTAssertEqual(sut.description, "Single")
        }
    }

    func testTypeEP() throws {
        try ["EP", "ep", "eP"].forEach {
            let sut = try XCTUnwrap(ReleaseType(typeString: $0))
            XCTAssertEqual(sut, .ep)
            XCTAssertEqual(sut.description, "EP")
        }
    }

    func testTypeVideo() throws {
        try ["Video", "video", "viDEo"].forEach {
            let sut = try XCTUnwrap(ReleaseType(typeString: $0))
            XCTAssertEqual(sut, .video)
            XCTAssertEqual(sut.description, "Video")
        }
    }

    func testTypeBoxedSet() throws {
        try ["Boxed set", "Boxed Set", "boxed set", "boxed SET"].forEach {
            let sut = try XCTUnwrap(ReleaseType(typeString: $0))
            XCTAssertEqual(sut, .boxedSet)
            XCTAssertEqual(sut.description, "Boxed set")
        }
    }

    func testTypeSplit() throws {
        try ["Split", "split", "sPLIt"].forEach {
            let sut = try XCTUnwrap(ReleaseType(typeString: $0))
            XCTAssertEqual(sut, .split)
            XCTAssertEqual(sut.description, "Split")
        }
    }

    func testTypeCompilation() throws {
        try ["Compilation", "compilation", "compilaTION"].forEach {
            let sut = try XCTUnwrap(ReleaseType(typeString: $0))
            XCTAssertEqual(sut, .compilation)
            XCTAssertEqual(sut.description, "Compilation")
        }
    }

    func testTypeSplitVideo() throws {
        try ["Split video", "Split Video", "split Video", "split VIDEO"].forEach {
            let sut = try XCTUnwrap(ReleaseType(typeString: $0))
            XCTAssertEqual(sut, .splitVideo)
            XCTAssertEqual(sut.description, "Split video")
        }
    }

    func testTypeCollaboration() throws {
        try ["Collaboration", "collaboration", "collaBORation"].forEach {
            let sut = try XCTUnwrap(ReleaseType(typeString: $0))
            XCTAssertEqual(sut, .collaboration)
            XCTAssertEqual(sut.description, "Collaboration")
        }
    }
}
