//
//  ModificationInfoTests.swift
//  Metal ArchivesTests
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

// swiftlint:disable implicitly_unwrapped_optional
import Kanna
@testable import Metal_Archives
import XCTest

final class ModificationInfoTests: XCTestCase {
    var sut: ModificationInfo!

    func testInit() throws {
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
        let html = try Kanna.HTML(html: htmlTag, encoding: .utf8)
        let table = try XCTUnwrap(html.at_css("table"))
        sut = ModificationInfo(element: table)
        let dateFormatter = DateFormatter.default

        let addedOnDate = try XCTUnwrap(sut.addedOnDate)
        XCTAssertEqual(addedOnDate, dateFormatter.date(from: "2019-05-15 05:37:16"))

        let modifiedOnDate = try XCTUnwrap(sut.modifiedOnDate)
        XCTAssertEqual(modifiedOnDate, dateFormatter.date(from: "2021-05-07 10:22:22"))

        let addedByUser = try XCTUnwrap(sut.addedByUser)
        XCTAssertEqual(addedByUser.name, "Krister Jensen")
        XCTAssertEqual(addedByUser.urlString, "https://www.metal-archives.com/users/Krister%20Jensen")

        let modifiedByUser = try XCTUnwrap(sut.modifiedByUser)
        XCTAssertEqual(modifiedByUser.name, "Putrid_Abomination")
        XCTAssertEqual(modifiedByUser.urlString, "https://www.metal-archives.com/users/Putrid_Abomination")
    }
}

// swiftlint:enable implicitly_unwrapped_optional
