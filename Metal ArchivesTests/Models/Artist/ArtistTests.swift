//
//  ArtistTests.swift
//  Metal ArchivesTests
//
//  Created by Thanh-Nhon Nguyen on 29/05/2021.
//

@testable import Metal_Archives
import XCTest

class ArtistTests: XCTestCase {
    func testChuck() throws {
        // Chuck Schuldiner
        // Full information (bio, trivia, rip,...)
        // https://www.metal-archives.com/artists/Chuck_Schuldiner/3012
        let sut = try XCTUnwrap(Artist(data: Data.fromHtml(fileName: "Chuck")))

        XCTAssertEqual(sut.artistName, "Chuck Schuldiner")
        XCTAssertEqual(sut.realFullName, "Charles Michael Schuldiner")
        XCTAssertEqual(sut.age, "34 (born May 13th, 1967)")
        XCTAssertEqual(sut.rip, "Dec 13th, 2001")
        XCTAssertEqual(sut.causeOfDeath, "Pneumonia")
        XCTAssertEqual(sut.origin, "United States (Glen Cove, New York)")
        XCTAssertEqual(sut.gender, "Male")
        XCTAssertEqual(sut.photoUrlString, "https://www.metal-archives.com/images/3/0/1/2/3012_artist.jpg?4208")
        let biographyHtmlString = try XCTUnwrap(sut.biographyHtmlString)
        XCTAssertTrue(biographyHtmlString.contains("Schuldiner was the singer"))
        XCTAssertTrue(sut.hasMoreBiography)
        let triviaHtmlString = try XCTUnwrap(sut.triviaHtmlString)
        XCTAssertTrue(triviaHtmlString.contains("Schuldiner is often referred to as"))

        // Past bands
        XCTAssertEqual(sut.pastRoles.count, 5)
        let pastControlDenied = try XCTUnwrap(sut.pastRoles[0])
        XCTAssertEqual(pastControlDenied.band.thumbnailInfo?.id, 549)
        XCTAssertEqual(pastControlDenied.band.thumbnailInfo?.urlString,
                       "https://www.metal-archives.com/bands/Control_Denied/549")
        XCTAssertEqual(pastControlDenied.band.name, "Control Denied")
        XCTAssertEqual(pastControlDenied.description, "Guitars, Vocals (1995-2001)")
        XCTAssertEqual(pastControlDenied.roleInReleases.count, 4)

        let controlDeniedFirstRole = try XCTUnwrap(pastControlDenied.roleInReleases.first)
        XCTAssertEqual(controlDeniedFirstRole.year, "1996")
        XCTAssertEqual(controlDeniedFirstRole.release.thumbnailInfo.id, 4274)
        XCTAssertEqual(controlDeniedFirstRole.release.thumbnailInfo.urlString,
                       "https://www.metal-archives.com/albums/Control_Denied/Demo/4274")
        XCTAssertEqual(controlDeniedFirstRole.release.thumbnailInfo.type, .release)
        XCTAssertEqual(controlDeniedFirstRole.release.title, "Demo")
        XCTAssertEqual(controlDeniedFirstRole.releaseAdditionalInfo, "Demo")
        XCTAssertEqual(controlDeniedFirstRole.description, "Guitars, Vocals")

        let controlDeniedLastRole = try XCTUnwrap(pastControlDenied.roleInReleases.last)
        XCTAssertEqual(controlDeniedLastRole.year, "1999")
        XCTAssertEqual(controlDeniedLastRole.release.thumbnailInfo.id, 2013)
        XCTAssertEqual(controlDeniedLastRole.release.thumbnailInfo.urlString,
                       "https://www.metal-archives.com/albums/Control_Denied/The_Fragile_Art_of_Existence/2013")
        XCTAssertEqual(controlDeniedLastRole.release.thumbnailInfo.type, .release)
        XCTAssertEqual(controlDeniedLastRole.release.title, "The Fragile Art of Existence")
        XCTAssertNil(controlDeniedLastRole.releaseAdditionalInfo)
        XCTAssertEqual(controlDeniedLastRole.description, "Guitars, Songwriting, Lyrics")

        let pastDeath = try XCTUnwrap(sut.pastRoles[1])
        XCTAssertEqual(pastDeath.band.thumbnailInfo?.id, 141)
        XCTAssertEqual(pastDeath.band.thumbnailInfo?.urlString,
                       "https://www.metal-archives.com/bands/Death/141")
        XCTAssertEqual(pastDeath.band.name, "Death")
        XCTAssertEqual(pastDeath.description, "Guitars, Vocals (1984-2001)")
        XCTAssertEqual(pastDeath.roleInReleases.count, 54)

        let pastMantas = try XCTUnwrap(sut.pastRoles[2])
        XCTAssertEqual(pastMantas.band.thumbnailInfo?.id, 35328)
        XCTAssertEqual(pastMantas.band.thumbnailInfo?.urlString,
                       "https://www.metal-archives.com/bands/Mantas/35328")
        XCTAssertEqual(pastMantas.band.name, "Mantas")
        XCTAssertEqual(pastMantas.description,
                       "As Charles \"Evil Chuck\" Schuldiner: Guitars, Vocals (additional) (1983-1984)")
        XCTAssertEqual(pastMantas.roleInReleases.count, 6)

        let pastSlaughter = try XCTUnwrap(sut.pastRoles[3])
        XCTAssertEqual(pastSlaughter.band.thumbnailInfo?.id, 376)
        XCTAssertEqual(pastSlaughter.band.thumbnailInfo?.urlString,
                       "https://www.metal-archives.com/bands/Slaughter/376")
        XCTAssertEqual(pastSlaughter.band.name, "Slaughter")
        XCTAssertEqual(pastSlaughter.description, "Guitars (1986)")
        XCTAssertEqual(pastSlaughter.roleInReleases.count, 1)

        let pastVoodoocult = try XCTUnwrap(sut.pastRoles[4])
        XCTAssertEqual(pastVoodoocult.band.thumbnailInfo?.id, 1599)
        XCTAssertEqual(pastVoodoocult.band.thumbnailInfo?.urlString,
                       "https://www.metal-archives.com/bands/Voodoocult/1599")
        XCTAssertEqual(pastVoodoocult.band.name, "Voodoocult")
        XCTAssertEqual(pastVoodoocult.description, "Guitars")
        XCTAssertEqual(pastVoodoocult.roleInReleases.count, 1)

        // Guest session
        XCTAssertEqual(sut.guestSessionRoles.count, 1)

        // Misc. staff
        XCTAssertEqual(sut.miscStaffRoles.count, 7)
    }

    func testRickRozz() throws {
        // https://www.metal-archives.com/artists/Rick_Rozz/11902
        let sut = try XCTUnwrap(Artist(data: Data.fromHtml(fileName: "RickRozz")))

        XCTAssertEqual(sut.artistName, "Rick Rozz")
        XCTAssertEqual(sut.realFullName, "Frederick DeLillo")
        XCTAssertEqual(sut.age, "54 (born Jan 9th, 1967)")
        XCTAssertNil(sut.rip)
        XCTAssertNil(sut.causeOfDeath)
        XCTAssertEqual(sut.origin, "United States (New York City, New York)")
        XCTAssertEqual(sut.gender, "Male")
        XCTAssertEqual(sut.photoUrlString, "https://www.metal-archives.com/images/1/1/9/0/11902_artist.jpg?3912")
        let biographyHtmlString = try XCTUnwrap(sut.biographyHtmlString)
        XCTAssertTrue(biographyHtmlString.contains("One of the founding members"))
        XCTAssertFalse(sut.hasMoreBiography)
        let triviaHtmlString = try XCTUnwrap(sut.triviaHtmlString)
        XCTAssertTrue(triviaHtmlString.contains("In a 1991 interview with Metal Forces"))

        XCTAssertEqual(sut.activeRoles.count, 3)
        XCTAssertEqual(sut.pastRoles.count, 8)
        XCTAssertEqual(sut.guestSessionRoles.count, 5)
        XCTAssertEqual(sut.miscStaffRoles.count, 3)
    }
}
