//
//  GenreStringToKeywordsTests.swift
//  Metal ArchivesTests
//
//  Created by Thanh-Nhon Nguyen on 28/08/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import XCTest
@testable import Metal_Archives

class GenreStringToKeywordsTests: XCTestCase {
    
    func testGenreStringToKeywords() {
        XCTAssertEqual("black metal".genreStringToKeywords(), ["black", "metal"])
        XCTAssertEqual("Doom/Stoner/Sludge".genreStringToKeywords(), ["Doom", "Stoner", "Sludge"])
        XCTAssertEqual("Experimental/Avant-garde".genreStringToKeywords(), ["Experimental", "Avant-garde"])
        XCTAssertEqual(#"123 m3talhead blackened-death symphonic/Pagan\ ambient\death metal Avant-gaRde"#.genreStringToKeywords(), ["blackened-death", "symphonic", "Pagan", "ambient", "death", "metal", "Avant-gaRde"])
    }
    
    func testGenerationOfPredicateString() {
        XCTAssertEqual("black metal".genreStringToKeywords().toPredicateString(), "genre CONTAINS[cd] 'black' || genre CONTAINS[cd] 'metal'")
        XCTAssertEqual("Doom/Stoner/Sludge".genreStringToKeywords().toPredicateString(), "genre CONTAINS[cd] 'Doom' || genre CONTAINS[cd] 'Stoner' || genre CONTAINS[cd] 'Sludge'")
        XCTAssertEqual("Experimental/Avant-garde".genreStringToKeywords().toPredicateString(), "genre CONTAINS[cd] 'Experimental' || genre CONTAINS[cd] 'Avant-garde'")
        XCTAssertEqual(#"123 m3talhead blackened-death symphonic/Pagan\ ambient\death metal Avant-gaRde"#.genreStringToKeywords().toPredicateString(), "genre CONTAINS[cd] 'blackened-death' || genre CONTAINS[cd] 'symphonic' || genre CONTAINS[cd] 'Pagan' || genre CONTAINS[cd] 'ambient' || genre CONTAINS[cd] 'death' || genre CONTAINS[cd] 'metal' || genre CONTAINS[cd] 'Avant-gaRde'")
    }
}

