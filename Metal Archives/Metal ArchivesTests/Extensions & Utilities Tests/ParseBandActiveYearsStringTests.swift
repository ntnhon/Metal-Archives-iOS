//
//  ParseBandActiveYearsStringTests.swift
//  Metal ArchivesTests
//
//  Created by Thanh-Nhon Nguyen on 15/05/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import XCTest
@testable import Metal_Archives

class ParseBandActiveYearsStringTests: XCTestCase {
    
    func testRemoveHTMLTagsAndNoisySpacesInCaseWithoutHTMLTag() {
        let testString = "\n\t\t        \t\t\t        \t\t\t\t        \t\t\n\t\t        \t\t\t1990-2003\t\t        \t\t\t\t(as Septic Flesh),\t\t        \t\t\n\t\t        \t\t\t2007-present\t\t        \t\t\t        "
        let resultString = testString.removeHTMLTagsAndNoisySpaces()
        let expectedString = "1990-2003 (as Septic Flesh), 2007-present"
        XCTAssertEqual(resultString, expectedString)
        
        let testString2 = "\n\t\t\t\t\t\n\t\t\t\t\t\t (R.I.P. 2001)\t\t\t\t\t\tSee also:\n\t\t\t\t\t\tex-Control Denied, ex-Mantas, ex-Slaughter, ex-Voodoocult\t\t\t\t\t\n\t\t\t\t"
        let resultString2 = testString2.removeHTMLTagsAndNoisySpaces()
        let expectedString2 = "(R.I.P. 2001) See also: ex-Control Denied, ex-Mantas, ex-Slaughter, ex-Voodoocult"
        XCTAssertEqual(resultString2, expectedString2)
    }

    func testRemoveHTMLTagsAndNoisySpacesInCaseWithHTMLTag() {
        let testString = "\n\t\t        \t\t\t        \t\t\t\t        \t\t\n\t\t        \t\t\t1994-1999\t\t        \t\t\t\t(as <a href=\"https://www.metal-archives.com/bands/Burn_the_Priest/39615\">Burn the Priest</a>),\t\t        \t\t\n\t\t        \t\t\t1999-present\t\t        \t\t\t        "
        let resultString = testString.removeHTMLTagsAndNoisySpaces()
        let expectedString = "1994-1999 (as Burn the Priest), 1999-present"
        XCTAssertEqual(resultString, expectedString)
    }

    func testRemoveHTMLTagsAndNoisySpacesInCaseComplexeAndQuestionMark() {
        let testString = "\n\t\t        \t\t\t        \t\t\t\t        \t\t\n\t\t        \t\t\t2006-?,\t\t        \t\t\n\t\t        \t\t\t?-2007\t\t        \t\t\t\t(as <strong>Splatter the Cadaver</strong>),\t\t        \t\t\n\t\t        \t\t\t2008\t\t        \t\t\t\t(as <strong>Splatter the Cadaver</strong>)\t\t        \t\t\t        "
        let resultString = testString.removeHTMLTagsAndNoisySpaces()
        let expectedString = "2006-?, ?-2007 (as Splatter the Cadaver), 2008 (as Splatter the Cadaver)"
        XCTAssertEqual(resultString, expectedString)
    }
}
