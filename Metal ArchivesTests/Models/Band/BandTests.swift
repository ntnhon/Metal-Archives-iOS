//
//  BandTests.swift
//  Metal ArchivesTests
//
//  Created by Thanh-Nhon Nguyen on 24/05/2021.
//

@testable import Metal_Archives
import XCTest

final class BandTests: XCTestCase {
    func testDeath() throws {
        let sut = try XCTUnwrap(Band(data: Data.fromHtml(fileName: "Death")))

        XCTAssertEqual(sut.id, "141")
        XCTAssertEqual(sut.name, "Death")
        XCTAssertEqual(sut.country, CountryManager.shared.country(by: \.isoCode, value: "US"))
        XCTAssertEqual(sut.genre, "Death Metal (early); Progressive Death Metal (later)")
        XCTAssertEqual(sut.status, .splitUp)
        XCTAssertEqual(sut.location, "Altamonte Springs, Florida")
        XCTAssertEqual(sut.yearOfCreation, "1984")
        XCTAssertEqual(sut.yearsActive, "1983-1984 (as Mantas), 1984-2001")
        let mantas = try XCTUnwrap(BandLite(urlString: "https://www.metal-archives.com/bands/Mantas/35328",
                                            name: "Mantas"))
        XCTAssertEqual(sut.oldBands.first, mantas)
        XCTAssertEqual(sut.lyricalTheme, "Death, Gore (early); Society, Enlightenment (later)")
        // swiftlint:disable:next line_length
        let labelThumbnailInfo = try XCTUnwrap(ThumbnailInfo(urlString: "https://www.metal-archives.com/labels/Nuclear_Blast/2",
                                                             type: .label))
        XCTAssertEqual(sut.lastLabel, .init(thumbnailInfo: labelThumbnailInfo,
                                            name: "Nuclear Blast"))
        XCTAssertEqual(sut.logoUrlString, "https://www.metal-archives.com/images/1/4/1/141_logo.png?3006")
        XCTAssertEqual(sut.photoUrlString, "https://www.metal-archives.com/images/1/4/1/141_photo.jpg?5804")

        // ModificationInfo
        let addedByUser = UserLite(name: "Disciple_Of_Metal",
                                   urlString: "https://www.metal-archives.com/users/Disciple_Of_Metal")
        let modifiedByUser = UserLite(name: "hondeth",
                                      urlString: "https://www.metal-archives.com/users/hondeth")
        let info = ModificationInfo(addedOnDate: DateFormatter.default.date(from: "2002-07-17 20:34:19"),
                                    modifiedOnDate: DateFormatter.default.date(from: "2021-05-05 18:53:44"),
                                    addedByUser: addedByUser,
                                    modifiedByUser: modifiedByUser)
        XCTAssertEqual(sut.modificationInfo, info)

        XCTAssertFalse(sut.isBookmarked)
        XCTAssertTrue(sut.isLastKnownLineUp)

        // Current line up
        XCTAssertEqual(sut.currentLineUp.count, 4)
        let chuck = try XCTUnwrap(sut.currentLineUp.first { $0.name == "Chuck Schuldiner" })
        // swiftlint:disable:next line_length
        let controlDenied = try XCTUnwrap(BandLite(urlString: "https://www.metal-archives.com/bands/Control_Denied/549",
                                                   name: "Control Denied"))
        let slaughter = try XCTUnwrap(BandLite(urlString: "https://www.metal-archives.com/bands/Slaughter/376",
                                               name: "Slaughter"))
        let voodooCult = try XCTUnwrap(BandLite(urlString: "https://www.metal-archives.com/bands/Voodoocult/1599",
                                                name: "Voodoocult"))
        // swiftlint:disable:next line_length
        let expectedChuckThumbnailInfo = try XCTUnwrap(ThumbnailInfo(urlString: "https://www.metal-archives.com/artists/Chuck_Schuldiner/3012",
                                                                     type: .artist))
        let expectedChuck = ArtistInBand(thumbnailInfo: expectedChuckThumbnailInfo,
                                         name: "Chuck Schuldiner",
                                         instruments: "Guitars, Vocals (1984-2001)",
                                         bands: [controlDenied, mantas, slaughter, voodooCult],
                                         // swiftlint:disable:next line_length
                                         seeAlso: "(R.I.P. 2001) See also: ex- Control Denied, ex-Mantas, ex-Slaughter, ex-Voodoocult")
//        XCTAssertEqual(chuck, expectedChuck)

        XCTAssertEqual(sut.pastMembers.count, 19)
        XCTAssertEqual(sut.liveMusicians.count, 7)
    }

    func testMysterium() throws {
        let sut = try XCTUnwrap(Band(data: Data.fromHtml(fileName: "Mysterium")))

        XCTAssertNotNil(sut)
        XCTAssertTrue(sut.isLastKnownLineUp)
        XCTAssertEqual(sut.currentLineUp.count, 7)
        XCTAssertEqual(sut.pastMembers.count, 5)
    }
}
