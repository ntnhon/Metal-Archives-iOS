//
//  ReleaseTests.swift
//  Metal ArchivesTests
//
//  Created by Thanh-Nhon Nguyen on 26/05/2021.
//

@testable import Metal_Archives
import XCTest

class ReleaseTests: XCTestCase {
    func testReleaseWithLyricsAndInstrumentalTracks() throws {
        // The Sound of Perseverance
        // https://www.metal-archives.com/albums/Death/The_Sound_of_Perseverance/618

        let sut = try XCTUnwrap(Release(data: Data.fromHtml(fileName: "TheSoundOfPerseverance")))

        XCTAssertEqual(sut.id, "618")
        XCTAssertEqual(sut.urlString, "https://www.metal-archives.com/albums/Death/The_Sound_of_Perseverance/618")
        XCTAssertEqual(sut.bands.count, 1)
        let death = try XCTUnwrap(sut.bands.first)
        XCTAssertEqual(death.thumbnailInfo.id, 141)
        XCTAssertEqual(death.thumbnailInfo.urlString, "https://www.metal-archives.com/bands/Death/141")
        XCTAssertEqual(death.name, "Death")
        XCTAssertEqual(sut.coverUrlString, "https://www.metal-archives.com/images/6/1/8/618.jpg?5800")
        XCTAssertEqual(sut.title, "The Sound of Perseverance")
        XCTAssertEqual(sut.type, .fullLength)
        XCTAssertEqual(sut.date, "August 31st, 1998")
        XCTAssertEqual(sut.catalogId, "NB 337-2")
        XCTAssertEqual(sut.label.name, "Nuclear Blast")
        let nuclearBlastThumbnailInfo = try XCTUnwrap(sut.label.thumbnailInfo)
        XCTAssertEqual(nuclearBlastThumbnailInfo.id, 2)
        XCTAssertEqual(nuclearBlastThumbnailInfo.urlString,
                       "https://www.metal-archives.com/labels/Nuclear_Blast/2")
        XCTAssertEqual(nuclearBlastThumbnailInfo.type, .label)
        XCTAssertEqual(sut.format, "CD")
        let additionalHtmlNote = try XCTUnwrap(sut.additionalHtmlNote)
        XCTAssertTrue(additionalHtmlNote.contains("<br> Logo redesigned by Strain.<br>"))
        XCTAssertEqual(sut.reviewCount, 29)
        XCTAssertEqual(sut.rating, 77)
        XCTAssertEqual(sut.otherInfo, [])
        XCTAssertNil(sut.modificationInfo.addedByUser)
        XCTAssertNil(sut.modificationInfo.addedOnDate)
        let modifiedByUser = try XCTUnwrap(sut.modificationInfo.modifiedByUser)
        XCTAssertEqual(modifiedByUser.name, "AndromedaVessel")
        XCTAssertEqual(modifiedByUser.urlString, "https://www.metal-archives.com/users/AndromedaVessel")
        XCTAssertEqual(sut.modificationInfo.modifiedOnDate,
                       DateFormatter.default.date(from: "2020-06-30 22:58:00"))
        XCTAssertFalse(sut.isBookmarked)

        // Songs
        XCTAssertEqual(sut.elements.count, 10)
        let scavengerOfHumanSorrow = ReleaseElement.song(number: "1.",
                                                         title: "Scavenger of Human Sorrow",
                                                         length: "06:54",
                                                         lyricId: "5678",
                                                         isInstrumental: false)
        XCTAssertEqual(sut.elements[0], scavengerOfHumanSorrow)

        let biteThePain = ReleaseElement.song(number: "2.",
                                              title: "Bite the Pain",
                                              length: "04:30",
                                              lyricId: "5679",
                                              isInstrumental: false)
        XCTAssertEqual(sut.elements[1], biteThePain)

        let spiritCrusher = ReleaseElement.song(number: "3.",
                                                title: "Spirit Crusher",
                                                length: "06:45",
                                                lyricId: "5680",
                                                isInstrumental: false)
        XCTAssertEqual(sut.elements[2], spiritCrusher)

        let storyToTell = ReleaseElement.song(number: "4.",
                                              title: "Story to Tell",
                                              length: "06:34",
                                              lyricId: "5681",
                                              isInstrumental: false)
        XCTAssertEqual(sut.elements[3], storyToTell)

        let fleshAndThePower = ReleaseElement.song(number: "5.",
                                                   title: "Flesh and the Power It Holds",
                                                   length: "08:26",
                                                   lyricId: "5682",
                                                   isInstrumental: false)
        XCTAssertEqual(sut.elements[4], fleshAndThePower)

        let voiceOfTheSoul = ReleaseElement.song(number: "6.",
                                                 title: "Voice of the Soul",
                                                 length: "03:43",
                                                 lyricId: nil,
                                                 isInstrumental: true)
        XCTAssertEqual(sut.elements[5], voiceOfTheSoul)

        let forgiveIsSuffer = ReleaseElement.song(number: "7.",
                                                  title: "To Forgive Is to Suffer",
                                                  length: "05:55",
                                                  lyricId: "5684",
                                                  isInstrumental: false)
        XCTAssertEqual(sut.elements[6], forgiveIsSuffer)

        let momentOfClarity = ReleaseElement.song(number: "8.",
                                                  title: "A Moment of Clarity",
                                                  length: "07:23",
                                                  lyricId: "5685",
                                                  isInstrumental: false)
        XCTAssertEqual(sut.elements[7], momentOfClarity)

        let painkiller = ReleaseElement.song(number: "9.",
                                             title: "Painkiller (Judas Priest cover)",
                                             length: "06:03",
                                             lyricId: "5686",
                                             isInstrumental: false)
        XCTAssertEqual(sut.elements[8], painkiller)

        XCTAssertEqual(sut.elements[9], ReleaseElement.length(value: "56:13"))

        // Band members
        XCTAssertEqual(sut.bandMembers.count, 1)
        let bandMember = try XCTUnwrap(sut.bandMembers.first)
        XCTAssertEqual(bandMember.name, "Death")
        XCTAssertEqual(bandMember.members.count, 4)

        let chuck = try XCTUnwrap(bandMember.members[0])
        XCTAssertEqual(chuck.thumbnailInfo.id, 3_012)
        XCTAssertEqual(chuck.thumbnailInfo.urlString,
                       "https://www.metal-archives.com/artists/Chuck_Schuldiner/3012")
        XCTAssertEqual(chuck.thumbnailInfo.type, .artist)
        XCTAssertEqual(chuck.name, "Chuck Schuldiner")
        XCTAssertEqual(chuck.additionalDetail, "R.I.P. 2001")
        XCTAssertEqual(chuck.lineUpType, .members)
        XCTAssertEqual(chuck.instruments, "Guitars, Vocals, Songwriting, Lyrics")

        let shannon = try XCTUnwrap(bandMember.members[1])
        XCTAssertEqual(shannon.thumbnailInfo.id, 3_079)
        XCTAssertEqual(shannon.thumbnailInfo.urlString,
                       "https://www.metal-archives.com/artists/Shannon_Hamm/3079")
        XCTAssertEqual(shannon.thumbnailInfo.type, .artist)
        XCTAssertEqual(shannon.name, "Shannon Hamm")
        XCTAssertNil(shannon.additionalDetail)
        XCTAssertEqual(shannon.lineUpType, .members)
        XCTAssertEqual(shannon.instruments, "Guitars")

        let scott = try XCTUnwrap(bandMember.members[2])
        XCTAssertEqual(scott.thumbnailInfo.id, 3_088)
        XCTAssertEqual(scott.thumbnailInfo.urlString,
                       "https://www.metal-archives.com/artists/Scott_Clendenin/3088")
        XCTAssertEqual(scott.thumbnailInfo.type, .artist)
        XCTAssertEqual(scott.name, "Scott Clendenin")
        XCTAssertEqual(scott.additionalDetail, "R.I.P. 2015")
        XCTAssertEqual(scott.lineUpType, .members)
        XCTAssertEqual(scott.instruments, "Bass")

        let richard = try XCTUnwrap(bandMember.members[3])
        XCTAssertEqual(richard.thumbnailInfo.id, 3_055)
        XCTAssertEqual(richard.thumbnailInfo.urlString,
                       "https://www.metal-archives.com/artists/Richard_Christy/3055")
        XCTAssertEqual(richard.thumbnailInfo.type, .artist)
        XCTAssertEqual(richard.name, "Richard Christy")
        XCTAssertNil(richard.additionalDetail)
        XCTAssertEqual(richard.lineUpType, .members)
        XCTAssertEqual(richard.instruments, "Drums")

        // Guest member
        XCTAssertTrue(sut.guestMembers.isEmpty)

        // Other staff
        XCTAssertEqual(sut.otherStaff.count, 6)
        let jim = try XCTUnwrap(sut.otherStaff[0])
        XCTAssertEqual(jim.thumbnailInfo.id, 15_326)
        XCTAssertEqual(jim.thumbnailInfo.urlString,
                       "https://www.metal-archives.com/artists/Jim_Morris/15326")
        XCTAssertEqual(jim.thumbnailInfo.type, .artist)
        XCTAssertEqual(jim.name, "Jim Morris")
        XCTAssertNil(jim.additionalDetail)
        XCTAssertEqual(jim.lineUpType, .other)
        XCTAssertEqual(jim.instruments, "Producer, Engineering, Mixing, Mastering")

        let alex = try XCTUnwrap(sut.otherStaff[1])
        XCTAssertEqual(alex.thumbnailInfo.id, 45_198)
        XCTAssertEqual(alex.thumbnailInfo.urlString,
                       "https://www.metal-archives.com/artists/Alex_McKnight/45198")
        XCTAssertEqual(alex.thumbnailInfo.type, .artist)
        XCTAssertEqual(alex.name, "Alex McKnight")
        XCTAssertNil(alex.additionalDetail)
        XCTAssertEqual(alex.lineUpType, .other)
        XCTAssertEqual(alex.instruments, "Photography (band)")

        let chuck2 = try XCTUnwrap(sut.otherStaff[2])
        XCTAssertEqual(chuck2.thumbnailInfo.id, 3_012)
        XCTAssertEqual(chuck2.thumbnailInfo.urlString,
                       "https://www.metal-archives.com/artists/Chuck_Schuldiner/3012")
        XCTAssertEqual(chuck2.thumbnailInfo.type, .artist)
        XCTAssertEqual(chuck2.name, "Chuck Schuldiner")
        XCTAssertEqual(chuck2.additionalDetail, "R.I.P. 2001")
        XCTAssertEqual(chuck2.lineUpType, .other)
        XCTAssertEqual(chuck2.instruments, "Producer")

        let maria = try XCTUnwrap(sut.otherStaff[3])
        XCTAssertEqual(maria.thumbnailInfo.id, 160_346)
        XCTAssertEqual(maria.thumbnailInfo.urlString,
                       "https://www.metal-archives.com/artists/Maria_Abril/160346")
        XCTAssertEqual(maria.thumbnailInfo.type, .artist)
        XCTAssertEqual(maria.name, "Maria Abril")
        XCTAssertNil(maria.additionalDetail)
        XCTAssertEqual(maria.lineUpType, .other)
        XCTAssertEqual(maria.instruments, "Art direction, Design")

        let gabe = try XCTUnwrap(sut.otherStaff[4])
        XCTAssertEqual(gabe.thumbnailInfo.id, 78_987)
        XCTAssertEqual(gabe.thumbnailInfo.urlString,
                       "https://www.metal-archives.com/artists/Gabe_Mera/78987")
        XCTAssertEqual(gabe.thumbnailInfo.type, .artist)
        XCTAssertEqual(gabe.name, "Gabe Mera")
        XCTAssertNil(gabe.additionalDetail)
        XCTAssertEqual(gabe.lineUpType, .other)
        XCTAssertEqual(gabe.instruments, "Art direction, Design")

        let travis = try XCTUnwrap(sut.otherStaff[5])
        XCTAssertEqual(travis.thumbnailInfo.id, 21_259)
        XCTAssertEqual(travis.thumbnailInfo.urlString,
                       "https://www.metal-archives.com/artists/Travis_Smith/21259")
        XCTAssertEqual(travis.thumbnailInfo.type, .artist)
        XCTAssertEqual(travis.name, "Travis Smith")
        XCTAssertNil(travis.additionalDetail)
        XCTAssertEqual(travis.lineUpType, .other)
        XCTAssertEqual(travis.instruments, "Cover art")

        // Reviews
        XCTAssertEqual(sut.reviews.count, 29)
        let firstReview = try XCTUnwrap(sut.reviews.first)
        XCTAssertEqual(firstReview.urlString,
                       // swiftlint:disable:next line_length
                       "https://www.metal-archives.com/reviews/Death/The_Sound_of_Perseverance/618/Hames_Jetfield/1014942")
        XCTAssertEqual(firstReview.title, "The Sound Of Perfection")
        XCTAssertEqual(firstReview.rating, 100)
        XCTAssertEqual(firstReview.author.urlString, "https://www.metal-archives.com/users/Hames_Jetfield")
        XCTAssertEqual(firstReview.author.name, "Hames_Jetfield")
        XCTAssertEqual(firstReview.date, "February 6th, 2021")

        let lastReview = try XCTUnwrap(sut.reviews.last)
        XCTAssertEqual(lastReview.urlString,
                       "https://www.metal-archives.com/reviews/Death/The_Sound_of_Perseverance/618/Vic/31")
        XCTAssertEqual(lastReview.title, "Oh, the hornets nest THIS...")
        XCTAssertEqual(lastReview.rating, 88)
        XCTAssertEqual(lastReview.author.urlString, "https://www.metal-archives.com/users/Vic")
        XCTAssertEqual(lastReview.author.name, "Vic")
        XCTAssertEqual(lastReview.date, "August 5th, 2002")
    }
}
