//
//  UserLiteTests.swift
//  Metal ArchivesTests
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

@testable import Metal_Archives
import XCTest

class UserLiteTests: XCTestCase {
    var sut: UserLite!

    override func setUp() {
        super.setUp()
        // swiftlint:disable:next line_length
        let htmlTag = #""<a href="https://www.metal-archives.com/users/Euthanasiast" class="profileMenu">Euthanasiast Doge</a>""#
        sut = UserLite(from: htmlTag)
    }

    func testInit() throws {
        let sut = try XCTUnwrap(sut)
        XCTAssertEqual(sut.name, "Euthanasiast Doge")
        XCTAssertEqual(sut.urlString, "https://www.metal-archives.com/users/Euthanasiast")
    }
}

extension UserLite: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name && lhs.urlString == rhs.urlString
    }
}
