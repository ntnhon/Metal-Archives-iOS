//
//  ReleaseTests.swift
//  Metal ArchivesTests
//
//  Created by Thanh-Nhon Nguyen on 26/05/2021.
//

@testable import Metal_Archives
import XCTest

// swiftlint:disable type_body_length function_body_length
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
        let scavengerOfHumanSorrow = ReleaseElement.song(.init(number: "1.",
                                                               title: "Scavenger of Human Sorrow",
                                                               length: "06:54",
                                                               lyricId: "5678",
                                                               isInstrumental: false))
        XCTAssertEqual(sut.elements[0], scavengerOfHumanSorrow)

        let biteThePain = ReleaseElement.song(.init(number: "2.",
                                                    title: "Bite the Pain",
                                                    length: "04:30",
                                                    lyricId: "5679",
                                                    isInstrumental: false))
        XCTAssertEqual(sut.elements[1], biteThePain)

        let spiritCrusher = ReleaseElement.song(.init(number: "3.",
                                                      title: "Spirit Crusher",
                                                      length: "06:45",
                                                      lyricId: "5680",
                                                      isInstrumental: false))
        XCTAssertEqual(sut.elements[2], spiritCrusher)

        let storyToTell = ReleaseElement.song(.init(number: "4.",
                                                    title: "Story to Tell",
                                                    length: "06:34",
                                                    lyricId: "5681",
                                                    isInstrumental: false))
        XCTAssertEqual(sut.elements[3], storyToTell)

        let fleshAndThePower = ReleaseElement.song(.init(number: "5.",
                                                         title: "Flesh and the Power It Holds",
                                                         length: "08:26",
                                                         lyricId: "5682",
                                                         isInstrumental: false))
        XCTAssertEqual(sut.elements[4], fleshAndThePower)

        let voiceOfTheSoul = ReleaseElement.song(.init(number: "6.",
                                                       title: "Voice of the Soul",
                                                       length: "03:43",
                                                       lyricId: nil,
                                                       isInstrumental: true))
        XCTAssertEqual(sut.elements[5], voiceOfTheSoul)

        let forgiveIsSuffer = ReleaseElement.song(.init(number: "7.",
                                                        title: "To Forgive Is to Suffer",
                                                        length: "05:55",
                                                        lyricId: "5684",
                                                        isInstrumental: false))
        XCTAssertEqual(sut.elements[6], forgiveIsSuffer)

        let momentOfClarity = ReleaseElement.song(.init(number: "8.",
                                                        title: "A Moment of Clarity",
                                                        length: "07:23",
                                                        lyricId: "5685",
                                                        isInstrumental: false))
        XCTAssertEqual(sut.elements[7], momentOfClarity)

        let painkiller = ReleaseElement.song(.init(number: "9.",
                                                   title: "Painkiller (Judas Priest cover)",
                                                   length: "06:03",
                                                   lyricId: "5686",
                                                   isInstrumental: false))
        XCTAssertEqual(sut.elements[8], painkiller)

        XCTAssertEqual(sut.elements[9], ReleaseElement.length("56:13"))

        // Band members
        XCTAssertEqual(sut.bandMembers.count, 1)
        let bandMember = try XCTUnwrap(sut.bandMembers.first)
        XCTAssertNil(bandMember.name)
        XCTAssertEqual(bandMember.members.count, 4)

        let chuck = try XCTUnwrap(bandMember.members[0])
        XCTAssertEqual(chuck.thumbnailInfo.id, 3012)
        XCTAssertEqual(chuck.thumbnailInfo.urlString,
                       "https://www.metal-archives.com/artists/Chuck_Schuldiner/3012")
        XCTAssertEqual(chuck.thumbnailInfo.type, .artist)
        XCTAssertEqual(chuck.name, "Chuck Schuldiner")
        XCTAssertEqual(chuck.additionalDetail, "R.I.P. 2001")
        XCTAssertEqual(chuck.lineUpType, .members)
        XCTAssertEqual(chuck.instruments, "Guitars, Vocals, Songwriting, Lyrics")

        let shannon = try XCTUnwrap(bandMember.members[1])
        XCTAssertEqual(shannon.thumbnailInfo.id, 3079)
        XCTAssertEqual(shannon.thumbnailInfo.urlString,
                       "https://www.metal-archives.com/artists/Shannon_Hamm/3079")
        XCTAssertEqual(shannon.thumbnailInfo.type, .artist)
        XCTAssertEqual(shannon.name, "Shannon Hamm")
        XCTAssertNil(shannon.additionalDetail)
        XCTAssertEqual(shannon.lineUpType, .members)
        XCTAssertEqual(shannon.instruments, "Guitars")

        let scott = try XCTUnwrap(bandMember.members[2])
        XCTAssertEqual(scott.thumbnailInfo.id, 3088)
        XCTAssertEqual(scott.thumbnailInfo.urlString,
                       "https://www.metal-archives.com/artists/Scott_Clendenin/3088")
        XCTAssertEqual(scott.thumbnailInfo.type, .artist)
        XCTAssertEqual(scott.name, "Scott Clendenin")
        XCTAssertEqual(scott.additionalDetail, "R.I.P. 2015")
        XCTAssertEqual(scott.lineUpType, .members)
        XCTAssertEqual(scott.instruments, "Bass")

        let richard = try XCTUnwrap(bandMember.members[3])
        XCTAssertEqual(richard.thumbnailInfo.id, 3055)
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
        XCTAssertEqual(sut.otherStaff.count, 1)
        let jim = try XCTUnwrap(sut.otherStaff[0].members[0])
        XCTAssertEqual(jim.thumbnailInfo.id, 15326)
        XCTAssertEqual(jim.thumbnailInfo.urlString,
                       "https://www.metal-archives.com/artists/Jim_Morris/15326")
        XCTAssertEqual(jim.thumbnailInfo.type, .artist)
        XCTAssertEqual(jim.name, "Jim Morris")
        XCTAssertNil(jim.additionalDetail)
        XCTAssertEqual(jim.lineUpType, .other)
        XCTAssertEqual(jim.instruments, "Producer, Engineering, Mixing, Mastering")

        let alex = try XCTUnwrap(sut.otherStaff[0].members[1])
        XCTAssertEqual(alex.thumbnailInfo.id, 45198)
        XCTAssertEqual(alex.thumbnailInfo.urlString,
                       "https://www.metal-archives.com/artists/Alex_McKnight/45198")
        XCTAssertEqual(alex.thumbnailInfo.type, .artist)
        XCTAssertEqual(alex.name, "Alex McKnight")
        XCTAssertNil(alex.additionalDetail)
        XCTAssertEqual(alex.lineUpType, .other)
        XCTAssertEqual(alex.instruments, "Photography (band)")

        let chuck2 = try XCTUnwrap(sut.otherStaff[0].members[2])
        XCTAssertEqual(chuck2.thumbnailInfo.id, 3012)
        XCTAssertEqual(chuck2.thumbnailInfo.urlString,
                       "https://www.metal-archives.com/artists/Chuck_Schuldiner/3012")
        XCTAssertEqual(chuck2.thumbnailInfo.type, .artist)
        XCTAssertEqual(chuck2.name, "Chuck Schuldiner")
        XCTAssertEqual(chuck2.additionalDetail, "R.I.P. 2001")
        XCTAssertEqual(chuck2.lineUpType, .other)
        XCTAssertEqual(chuck2.instruments, "Producer")

        let maria = try XCTUnwrap(sut.otherStaff[0].members[3])
        XCTAssertEqual(maria.thumbnailInfo.id, 160_346)
        XCTAssertEqual(maria.thumbnailInfo.urlString,
                       "https://www.metal-archives.com/artists/Maria_Abril/160346")
        XCTAssertEqual(maria.thumbnailInfo.type, .artist)
        XCTAssertEqual(maria.name, "Maria Abril")
        XCTAssertNil(maria.additionalDetail)
        XCTAssertEqual(maria.lineUpType, .other)
        XCTAssertEqual(maria.instruments, "Art direction, Design")

        let gabe = try XCTUnwrap(sut.otherStaff[0].members[4])
        XCTAssertEqual(gabe.thumbnailInfo.id, 78987)
        XCTAssertEqual(gabe.thumbnailInfo.urlString,
                       "https://www.metal-archives.com/artists/Gabe_Mera/78987")
        XCTAssertEqual(gabe.thumbnailInfo.type, .artist)
        XCTAssertEqual(gabe.name, "Gabe Mera")
        XCTAssertNil(gabe.additionalDetail)
        XCTAssertEqual(gabe.lineUpType, .other)
        XCTAssertEqual(gabe.instruments, "Art direction, Design")

        let travis = try XCTUnwrap(sut.otherStaff[0].members[5])
        XCTAssertEqual(travis.thumbnailInfo.id, 21259)
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

    func testSplitRelease() throws {
        // Letárgica Mortis
        // swiftlint:disable:next line_length
        // https://www.metal-archives.com/albums/Blestema_-_Arkanus_Mors_-_Grimorium_Serpent/Letárgica_Mortis/948910

        let sut = try XCTUnwrap(Release(data: Data.fromHtml(fileName: "LetargicaMortis")))

        XCTAssertEqual(sut.id, "948910")
        XCTAssertEqual(sut.urlString,
                       // swiftlint:disable:next line_length
                       "https://www.metal-archives.com/albums/Blestema_-_Arkanus_Mors_-_Grimorium_Serpent/Let%C3%A1rgica_Mortis/948910")

        // Bands
        XCTAssertEqual(sut.bands.count, 3)
        // swiftlint:disable:next line_length
        let blestema = try XCTUnwrap(BandLite(urlString: "https://www.metal-archives.com/bands/Blestema/3540297107", name: "Blestema"))
        XCTAssertEqual(sut.bands[0], blestema)

        // swiftlint:disable:next line_length
        let arkanusMors = try XCTUnwrap(BandLite(urlString: "https://www.metal-archives.com/bands/Arkanus_Mors/3540481590", name: "Arkanus Mors"))
        XCTAssertEqual(sut.bands[1], arkanusMors)

        // swiftlint:disable:next line_length
        let grimoriumSerpent = try XCTUnwrap(BandLite(urlString: "https://www.metal-archives.com/bands/Grimorium_Serpent/3540488692", name: "Grimorium Serpent"))
        XCTAssertEqual(sut.bands[2], grimoriumSerpent)

        XCTAssertEqual(sut.title, "Letárgica Mortis")
        XCTAssertEqual(sut.type, .split)
        XCTAssertEqual(sut.date, "May 18th, 2021")
        XCTAssertEqual(sut.catalogId, "ER005")
        XCTAssertEqual(sut.label.name, "Entropy Records")
        let labelThumbnailInfo = try XCTUnwrap(sut.label.thumbnailInfo)
        XCTAssertEqual(labelThumbnailInfo.id, 53786)
        XCTAssertEqual(labelThumbnailInfo.urlString,
                       "https://www.metal-archives.com/labels/Entropy_Records/53786")
        XCTAssertEqual(labelThumbnailInfo.type, .label)
        XCTAssertEqual(sut.format, "CD")
        XCTAssertNil(sut.additionalHtmlNote)
        XCTAssertNil(sut.reviewCount)
        XCTAssertNil(sut.rating)
        XCTAssertEqual(sut.otherInfo, [])
        XCTAssertNotNil(sut.modificationInfo.addedByUser)
        XCTAssertNotNil(sut.modificationInfo.addedOnDate)
        XCTAssertNotNil(sut.modificationInfo.modifiedByUser)
        XCTAssertNotNil(sut.modificationInfo.modifiedOnDate)
        XCTAssertFalse(sut.isBookmarked)

        // Songs
        XCTAssertEqual(sut.elements.count, 9)
        let firstTrack = ReleaseElement.song(.init(number: "1.",
                                                   title: "Grimorium Serpent - Golden Horns",
                                                   length: "05:38",
                                                   lyricId: nil,
                                                   isInstrumental: false))
        XCTAssertEqual(sut.elements[0], firstTrack)

        let secondTrack = ReleaseElement.song(.init(number: "2.",
                                                    title: "Grimorium Serpent - Ritual of the Nine Weeks",
                                                    length: "05:31",
                                                    lyricId: nil,
                                                    isInstrumental: false))
        XCTAssertEqual(sut.elements[1], secondTrack)

        XCTAssertEqual(sut.elements[8], ReleaseElement.length("45:41"))

        // Band members
        XCTAssertEqual(sut.bandMembers.count, 3)
        let firstBand = try XCTUnwrap(sut.bandMembers.first { $0.name == "Blestema" })
        XCTAssertEqual(firstBand.members.count, 3)

        let secondBand = try XCTUnwrap(sut.bandMembers.first { $0.name == "Arkanus Mors" })
        XCTAssertEqual(secondBand.members.count, 5)

        let thirdBand = try XCTUnwrap(sut.bandMembers.first { $0.name == "Grimorium Serpent" })
        XCTAssertEqual(thirdBand.members.count, 4)

        XCTAssertTrue(sut.guestMembers.isEmpty)
        XCTAssertTrue(sut.otherStaff.isEmpty)
        XCTAssertTrue(sut.reviews.isEmpty)
    }

    func test3CdsRelease() throws {
        // Human
        // https://www.metal-archives.com/albums/Death/Human/433097
        let sut = try XCTUnwrap(Release(data: Data.fromHtml(fileName: "Human_3CDs")))

        XCTAssertEqual(sut.id, "433097")
        XCTAssertEqual(sut.urlString,
                       "https://www.metal-archives.com/albums/Death/Human/433097")

        // Bands
        XCTAssertEqual(sut.bands.count, 1)
        let death = try XCTUnwrap(BandLite(urlString: "https://www.metal-archives.com/bands/Death/141",
                                           name: "Death"))
        XCTAssertEqual(sut.bands[0], death)

        XCTAssertEqual(sut.title, "Human")
        XCTAssertEqual(sut.type, .fullLength)
        XCTAssertEqual(sut.date, "June 21st, 2011")
        XCTAssertEqual(sut.catalogId, "RR 7166")
        XCTAssertEqual(sut.label.name, "Relapse Records")
        let labelThumbnailInfo = try XCTUnwrap(sut.label.thumbnailInfo)
        XCTAssertEqual(labelThumbnailInfo.id, 8)
        XCTAssertEqual(labelThumbnailInfo.urlString,
                       "https://www.metal-archives.com/labels/Relapse_Records/8")
        XCTAssertEqual(labelThumbnailInfo.type, .label)
        XCTAssertEqual(sut.format, "3CD")
        let additionalHtmlNote = try XCTUnwrap(sut.additionalHtmlNote)
        XCTAssertTrue(additionalHtmlNote.contains("Tracks 13-17 Human"))
        XCTAssertEqual(sut.reviewCount, 28)
        XCTAssertEqual(sut.rating, 93)
        XCTAssertEqual(sut.otherInfo.count, 2)
        XCTAssertTrue(sut.otherInfo.contains("Digipak, Remastered, Limited edition"))
        XCTAssertTrue(sut.otherInfo.contains("2000 copies"))
        XCTAssertNotNil(sut.modificationInfo.addedByUser)
        XCTAssertNotNil(sut.modificationInfo.addedOnDate)
        XCTAssertNotNil(sut.modificationInfo.modifiedByUser)
        XCTAssertNotNil(sut.modificationInfo.modifiedOnDate)
        XCTAssertFalse(sut.isBookmarked)

        // Songs
        XCTAssertEqual(sut.elements.count, 52)
        let firstDisc = ReleaseElement.disc("Disc 1 - Human")
        XCTAssertEqual(sut.elements.first, firstDisc)

        let lastLength = ReleaseElement.length("01:08:00")
        XCTAssertEqual(sut.elements.last, lastLength)

        // Band members
        XCTAssertEqual(sut.bandMembers.count, 1)
        let originalBandMembers = try XCTUnwrap(sut.bandMembers.first)
        XCTAssertEqual(originalBandMembers.name, "Original line-up")
        XCTAssertEqual(originalBandMembers.members.count, 4)

        // Guest
        XCTAssertEqual(sut.guestMembers.count, 2)
        let originalGuestMembers = try XCTUnwrap(sut.guestMembers
            .first { $0.name == "Original line-up" })
        XCTAssertEqual(originalGuestMembers.members.count, 1)

        let additionalGuestMembers = try XCTUnwrap(sut.guestMembers
            .first { $0.name == "Additional line-up" })
        XCTAssertEqual(additionalGuestMembers.members.count, 2)

        // Other staff
        XCTAssertEqual(sut.otherStaff.count, 2)
        let originalStaff = try XCTUnwrap(sut.otherStaff
            .first { $0.name == "Original line-up" })
        XCTAssertEqual(originalStaff.members.count, 7)

        let additionalSatff = try XCTUnwrap(sut.otherStaff
            .first { $0.name == "Additional line-up" })
        XCTAssertEqual(additionalSatff.members.count, 5)

        XCTAssertEqual(sut.reviews.count, 28)
    }
}

// swiftlint:enable type_body_length function_body_length
