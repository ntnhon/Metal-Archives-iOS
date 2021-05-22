//
//  ModificationInfoTests.swift
//  Metal ArchivesTests
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

@testable import Metal_Archives
import XCTest

class ModificationInfoTests: XCTestCase {
    var sut: ModificationInfo!

    override func setUp() {
        super.setUp()
        // swiftlint:disable line_length
        let htmlTag = """
                 <table>
                 <tr>
                 <td>Added by: <a href="https://www.metal-archives.com/users/Krister%20Jensen" class="profileMenu">Krister Jensen</a></td>
                 <td align="right">Modified by: <a href="https://www.metal-archives.com/users/Putrid_Abomination" class="profileMenu">Putrid_Abomination</a></td>
                 </tr>
                 <tr>
                 <td>Added on: 2019-05-15 05:37:16</td>
                 <td align="right">Last modified on: 2021-05-07 10:22:22</td>
                 </tr>
                 <tr>
                 <td valign="top">
                 &nbsp;
                 </td>
                 <td align="right" valign="top">
                 </td>
                 </tr>
                 </table>
            """
        // swiftlint:enable line_length
        sut = ModificationInfo(from: htmlTag)
    }

    func testInit() throws {
        let dateFormatter = DateFormatter.default

        let addedOnDate = try XCTUnwrap(sut.addedOnDate)
        XCTAssertEqual(addedOnDate, dateFormatter.date(from: "2019-05-15 05:37:16"))

        let modifiedOnDate = try XCTUnwrap(sut.modifiedOnDate)
        XCTAssertEqual(modifiedOnDate, dateFormatter.date(from: "2021-05-07 10:22:22"))

        let addedByUser = try XCTUnwrap(sut.addedByUser)
        // swiftlint:disable:next line_length
        let expectedAddedByUser = UserLite(from: #"<a href="https://www.metal-archives.com/users/Krister%20Jensen" class="profileMenu">Krister Jensen</a>"#)
        XCTAssertEqual(addedByUser, expectedAddedByUser)

        let modifiedByUser = try XCTUnwrap(sut.modifiedByUser)
        // swiftlint:disable:next line_length
        let expectedModifiedByUser = UserLite(from: #"<a href="https://www.metal-archives.com/users/Putrid_Abomination" class="profileMenu">Putrid_Abomination</a>"#)
        XCTAssertEqual(modifiedByUser, expectedModifiedByUser)
    }
}
