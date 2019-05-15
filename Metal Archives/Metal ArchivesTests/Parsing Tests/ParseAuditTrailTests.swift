//
//  ParseAuditTrailTests.swift
//  Metal ArchivesTests
//
//  Created by Thanh-Nhon Nguyen on 15/05/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import XCTest
@testable import Metal_Archives

class ParseAuditTrailTests: XCTestCase {
    
    func testParseAuditTrailWithCompleteInformation() {
        let inputString = """
        <table>
        <tr>
            <td>Added by: <a href="https://www.metal-archives.com/users/Disciple_Of_Metal" class="profileMenu">Disciple_Of_Metal</a></td>
            <td align="right">Modified by: <a href="https://www.metal-archives.com/users/beardovdoom" class="profileMenu">beardovdoom</a></td>
        </tr>
        <tr>
            <td>Added on: 2002-07-17 20:34:19</td>
            <td align="right">Last modified on: 2019-05-10 16:39:58</td>
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
        let auditTrail = AuditTrail(from: inputString)
        XCTAssertNotNil(auditTrail)
        
        XCTAssertEqual(auditTrail.addedByUser!.name, "Disciple_Of_Metal")
        XCTAssertEqual(auditTrail.addedByUser!.urlString, "https://www.metal-archives.com/users/Disciple_Of_Metal")
        
        XCTAssertEqual(auditTrail.modifiedByUser!.name, "beardovdoom")
        XCTAssertEqual(auditTrail.modifiedByUser!.urlString, "https://www.metal-archives.com/users/beardovdoom")
        
        XCTAssertEqual(auditTrail.addedOnDate, defaultDateFormatter.date(from: "2002-07-17 20:34:19"))
        XCTAssertEqual(auditTrail.modifiedOnDate, defaultDateFormatter.date(from: "2019-05-10 16:39:58"))
    }
    
    func testParseAuditTrailWithIncompletionInformation() {
        let inputString = """
        <table>
        <tr>
            <td>Added by: (Unknown user)</td>
            <td align="right">Modified by: (Unknown user)</td>
        </tr>
        <tr>
            <td>Added on: N/A</td>
            <td align="right">Last modified on: N/A</td>
        </tr>
        <tr>
            <td valign="top">
                                    &nbsp;
                            </td>
            <td align="right" valign="top">
                                            </td>
        </tr>
                    <td class="writeAction" colspan="2">Duplicate? Please <a href="javascript:popupReportDialog(2, 7656);">file a report</a> for merging.</td>
            </table>
        """
        let auditTrail = AuditTrail(from: inputString)
        XCTAssertNotNil(auditTrail)
        XCTAssertNil(auditTrail.addedByUser)
        XCTAssertNil(auditTrail.addedOnDate)
        XCTAssertNil(auditTrail.modifiedByUser)
        XCTAssertNil(auditTrail.modifiedOnDate)
    }

}
