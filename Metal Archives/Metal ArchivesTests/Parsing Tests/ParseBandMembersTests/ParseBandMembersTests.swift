//
//  ParseBandMembersTests.swift
//  Metal ArchivesTests
//
//  Created by Thanh-Nhon Nguyen on 15/05/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import XCTest
@testable import Metal_Archives
@testable import Kanna

class ParseBandMembersTests: XCTestCase {
    
    func testParseArtistsWithCompleteInformation() {
        // Given
        // Load from mock file
        // Original url: https://www.metal-archives.com/bands/Death/141
        let testBundle = Bundle(for: type(of: self))
        let path = testBundle.path(forResource: "DeathLastKnownLineup", ofType: "txt")!
        let inputString = try! String(contentsOfFile: path)
        let doc = try! Kanna.HTML(html: inputString, encoding: String.Encoding.utf8)
        
        // When
        let artists = Band.parseBandArtists(inDiv: doc.at_css("table")!)
    
        /*
         Attention to "&nbsp;" space
         copy this " "
         */

        // Then
        XCTAssertEqual(artists!.count, 4, "List of artists should be parsed successfully.")
        
        // 1: Chuck Schuldiner
        XCTAssertEqual(artists![0].name, "Chuck Schuldiner")
        XCTAssertEqual(artists![0].instrumentsInBand, "Guitars, Vocals (1984-2001)")
        XCTAssertEqual(artists![0].seeAlsoString, "(R.I.P. 2001) See also: ex-Control Denied, ex-Mantas, ex-Slaughter, ex-Voodoocult")
        XCTAssertEqual(artists![0].bands?.count, 4)
        XCTAssertEqual(artists![0].bands![0].name, "Control Denied")
        XCTAssertEqual(artists![0].bands![0].urlString, "https://www.metal-archives.com/bands/Control_Denied/549")
        XCTAssertEqual(artists![0].bands![1].name, "Mantas")
        XCTAssertEqual(artists![0].bands![1].urlString, "https://www.metal-archives.com/bands/Mantas/35328")
        XCTAssertEqual(artists![0].bands![2].name, "Slaughter")
        XCTAssertEqual(artists![0].bands![2].urlString, "https://www.metal-archives.com/bands/Slaughter/376")
        XCTAssertEqual(artists![0].bands![3].name, "Voodoocult")
        XCTAssertEqual(artists![0].bands![3].urlString, "https://www.metal-archives.com/bands/Voodoocult/1599")
        
        // 2: Scott Clendenin
        XCTAssertEqual(artists![1].name, "Scott Clendenin")
        XCTAssertEqual(artists![1].instrumentsInBand, "Bass (1996-2001)")
        XCTAssertEqual(artists![1].seeAlsoString, "(R.I.P. 2015) See also: ex-Control Denied")
        XCTAssertEqual(artists![1].bands?.count, 1)
        XCTAssertEqual(artists![1].bands![0].name, "Control Denied")
        XCTAssertEqual(artists![1].bands![0].urlString, "https://www.metal-archives.com/bands/Control_Denied/549")
        
        // 3: Richard Christy
        XCTAssertEqual(artists![2].name, "Richard Christy")
        XCTAssertEqual(artists![2].instrumentsInBand, "Drums (1996-2001)")
        XCTAssertEqual(artists![2].seeAlsoString, "See also: Charred Walls of the Damned, Monument of Bones, ex-Burning Inside, ex-Control Denied, Boar Glue, ex-Iced Earth, ex-Tiwanaku, ex-Demons and Wizards (live), ex-Incantation (live), ex-Wykked Wytch (live), ex-Acheron, ex-Leash Law, ex-Public Assassin, ex-Caninus, ex-Bung Dizeez (live), ex-Syzygy (live)")
        XCTAssertEqual(artists![2].bands?.count, 12)
        XCTAssertEqual(artists![2].bands![0].name, "Charred Walls of the Damned")
        XCTAssertEqual(artists![2].bands![0].urlString, "https://www.metal-archives.com/bands/Charred_Walls_of_the_Damned/3540299757")
        XCTAssertEqual(artists![2].bands![1].name, "Monument of Bones")
        XCTAssertEqual(artists![2].bands![1].urlString, "https://www.metal-archives.com/bands/Monument_of_Bones/127290")
        XCTAssertEqual(artists![2].bands![2].name, "Burning Inside")
        XCTAssertEqual(artists![2].bands![2].urlString, "https://www.metal-archives.com/bands/Burning_Inside/1233")
        XCTAssertEqual(artists![2].bands![3].name, "Control Denied")
        XCTAssertEqual(artists![2].bands![3].urlString, "https://www.metal-archives.com/bands/Control_Denied/549")
        XCTAssertEqual(artists![2].bands![4].name, "Iced Earth")
        XCTAssertEqual(artists![2].bands![4].urlString, "https://www.metal-archives.com/bands/Iced_Earth/4")
        XCTAssertEqual(artists![2].bands![5].name, "Tiwanaku")
        XCTAssertEqual(artists![2].bands![5].urlString, "https://www.metal-archives.com/bands/Tiwanaku/17095")
        XCTAssertEqual(artists![2].bands![6].name, "Demons and Wizards")
        XCTAssertEqual(artists![2].bands![6].urlString, "https://www.metal-archives.com/bands/Demons_%26_Wizards/158")
        XCTAssertEqual(artists![2].bands![7].name, "Incantation")
        XCTAssertEqual(artists![2].bands![7].urlString, "https://www.metal-archives.com/bands/Incantation/885")
        XCTAssertEqual(artists![2].bands![8].name, "Wykked Wytch")
        XCTAssertEqual(artists![2].bands![8].urlString, "https://www.metal-archives.com/bands/Wykked_Wytch/3968")
        XCTAssertEqual(artists![2].bands![9].name, "Acheron")
        XCTAssertEqual(artists![2].bands![9].urlString, "https://www.metal-archives.com/bands/Acheron/123")
        XCTAssertEqual(artists![2].bands![10].name, "Leash Law")
        XCTAssertEqual(artists![2].bands![10].urlString, "https://www.metal-archives.com/bands/Leash_Law/8580")
        XCTAssertEqual(artists![2].bands![11].name, "Public Assassin")
        XCTAssertEqual(artists![2].bands![11].urlString, "https://www.metal-archives.com/bands/Public_Assassin/32920")
        
        // 4: Shannon Hamm
        XCTAssertEqual(artists![3].name, "Shannon Hamm")
        XCTAssertEqual(artists![3].instrumentsInBand, "Guitars (1996-2001)")
        XCTAssertEqual(artists![3].seeAlsoString, "See also: Beyond Unknown, ex-Control Denied, ex-Metalstorm, ex-Synesis Absorption, ex-Order of Ennead (live), ex-Talonzfury")
        XCTAssertEqual(artists![3].bands?.count, 5)
        XCTAssertEqual(artists![3].bands![0].name, "Beyond Unknown")
        XCTAssertEqual(artists![3].bands![0].urlString, "https://www.metal-archives.com/bands/Beyond_Unknown/3540387976")
        XCTAssertEqual(artists![3].bands![1].name, "Control Denied")
        XCTAssertEqual(artists![3].bands![1].urlString, "https://www.metal-archives.com/bands/Control_Denied/549")
        XCTAssertEqual(artists![3].bands![2].name, "Metalstorm")
        XCTAssertEqual(artists![3].bands![2].urlString, "https://www.metal-archives.com/bands/Metalstorm/91344")
        XCTAssertEqual(artists![3].bands![3].name, "Synesis Absorption")
        XCTAssertEqual(artists![3].bands![3].urlString, "https://www.metal-archives.com/bands/Synesis_Absorption/3540320347")
        XCTAssertEqual(artists![3].bands![4].name, "Order of Ennead")
        XCTAssertEqual(artists![3].bands![4].urlString, "https://www.metal-archives.com/bands/Order_of_Ennead/3540265080")
    }
    
    func testParseArtistsWithIncompleteInformation() {
        // Given
        // Load from mock file
        // Original url: https://www.metal-archives.com/bands/Graves/3540442067
        let testBundle = Bundle(for: type(of: self))
        let path = testBundle.path(forResource: "GravesCurrentLineup", ofType: "txt")!
        let inputString = try! String(contentsOfFile: path)
        let doc = try! Kanna.HTML(html: inputString, encoding: String.Encoding.utf8)
        
        // When
        let artists = Band.parseBandArtists(inDiv: doc.at_css("table")!)
        
        // Then
        XCTAssertEqual(artists!.count, 3, "List of artists should be parsed successfully.")
        
        // 1: Necro.
        XCTAssertEqual(artists![0].name, "Necro.")
        XCTAssertEqual(artists![0].instrumentsInBand, "Drums")
        XCTAssertNil(artists![0].seeAlsoString)
        XCTAssertNil(artists![0].bands)
        
        // 2: M.v.K
        XCTAssertEqual(artists![1].name, "M.v.K")
        XCTAssertEqual(artists![1].instrumentsInBand, "Guitars")
        XCTAssertEqual(artists![1].seeAlsoString, "See also: S.U.N.D.S., ex-Nihilum, ex-Vermen, Cold June, ex-Flagellum Dei, ex-Revage (live), ex-Cold Floor to Embrace, ex-W.O.U.N.D.")
        XCTAssertEqual(artists![1].bands?.count, 5)
        XCTAssertEqual(artists![1].bands![0].name, "S.U.N.D.S.")
        XCTAssertEqual(artists![1].bands![0].urlString, "https://www.metal-archives.com/bands/S.U.N.D.S./60212")
        XCTAssertEqual(artists![1].bands![1].name, "Nihilum")
        XCTAssertEqual(artists![1].bands![1].urlString, "https://www.metal-archives.com/bands/Nihilum/39545")
        XCTAssertEqual(artists![1].bands![2].name, "Vermen")
        XCTAssertEqual(artists![1].bands![2].urlString, "https://www.metal-archives.com/bands/Vermen/59553")
        XCTAssertEqual(artists![1].bands![3].name, "Flagellum Dei")
        XCTAssertEqual(artists![1].bands![3].urlString, "https://www.metal-archives.com/bands/Flagellum_Dei/11146")
        XCTAssertEqual(artists![1].bands![4].name, "Revage")
        XCTAssertEqual(artists![1].bands![4].urlString, "https://www.metal-archives.com/bands/Revage/54995")
        
        // 3: N.
        XCTAssertEqual(artists![2].name, "N.")
        XCTAssertEqual(artists![2].instrumentsInBand, "Vocals")
        XCTAssertNil(artists![2].seeAlsoString)
        XCTAssertNil(artists![2].bands)
    }
}
