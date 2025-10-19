//
//  ReleaseLineUpViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 26/10/2022.
//

import Foundation

enum ReleaseLineUpMode: CaseIterable, CustomStringConvertible {
    case complete, bandMembers, guestMembers, otherStaff

    var description: String {
        switch self {
        case .complete:
            "Complete lineup"
        case .bandMembers:
            "Band members"
        case .guestMembers:
            "Guest/session musicians"
        case .otherStaff:
            "Other staff"
        }
    }
}

struct TitledLineUp: Hashable {
    let title: String?
    let members: [BandInRelease]

    func hash(into hasher: inout Hasher) {
        if let title {
            hasher.combine(title)
        }
        hasher.combine(members)
    }
}

final class ReleaseLineUpViewModel: ObservableObject {
    private let completeCount: Int
    private let bandMembersCount: Int
    private let bandMembers: [BandInRelease]
    private let guestMembersCount: Int
    private let guestMembers: [BandInRelease]
    private let otherStaffCount: Int
    private let otherStaff: [BandInRelease]
    let applicableModes: [ReleaseLineUpMode]

    init(release: Release) {
        let bandMembersCount = release.bandMembers.map(\.members.count).reduce(0, +)
        let guestMembersCount = release.guestMembers.map(\.members.count).reduce(0, +)
        let otherStaffCount = release.otherStaff.map(\.members.count).reduce(0, +)

        completeCount = bandMembersCount + guestMembersCount + otherStaffCount
        self.bandMembersCount = bandMembersCount
        bandMembers = release.bandMembers
        self.guestMembersCount = guestMembersCount
        guestMembers = release.guestMembers
        self.otherStaffCount = otherStaffCount
        otherStaff = release.otherStaff

        var applicableModes = [ReleaseLineUpMode]()
        if completeCount > 0 { applicableModes.append(.complete) }
        if bandMembersCount > 0 { applicableModes.append(.bandMembers) }
        if guestMembersCount > 0 { applicableModes.append(.guestMembers) }
        if otherStaffCount > 0 { applicableModes.append(.otherStaff) }
        self.applicableModes = applicableModes
    }

    func title(for mode: ReleaseLineUpMode) -> String {
        let count = count(for: mode)
        return "\(mode.description) (\(count))"
    }

    private func count(for mode: ReleaseLineUpMode) -> Int {
        switch mode {
        case .complete:
            completeCount
        case .bandMembers:
            bandMembersCount
        case .guestMembers:
            guestMembersCount
        case .otherStaff:
            otherStaffCount
        }
    }

    func lineUps(for mode: ReleaseLineUpMode) -> [TitledLineUp] {
        switch mode {
        case .complete:
            var lineUps = [TitledLineUp]()
            if bandMembersCount > 0 {
                lineUps.append(.init(title: "Band members", members: bandMembers))
            }
            if guestMembersCount > 0 {
                lineUps.append(.init(title: "Guest/session musicians", members: guestMembers))
            }
            if otherStaffCount > 0 {
                lineUps.append(.init(title: "Other staff", members: otherStaff))
            }
            return lineUps
        case .bandMembers:
            return [.init(title: nil, members: bandMembers)]
        case .guestMembers:
            return [.init(title: nil, members: guestMembers)]
        case .otherStaff:
            return [.init(title: nil, members: otherStaff)]
        }
    }
}
