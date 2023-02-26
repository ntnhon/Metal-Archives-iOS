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
        case .complete: return "Complete lineup"
        case .bandMembers: return "Band members"
        case .guestMembers: return "Guest/session musicians"
        case .otherStaff: return "Other staff"
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
        let bandMembersCount = release.bandMembers.map { $0.members.count }.reduce(0, +)
        let guestMembersCount = release.guestMembers.map { $0.members.count }.reduce(0, +)
        let otherStaffCount = release.otherStaff.map { $0.members.count }.reduce(0, +)

        self.completeCount = bandMembersCount + guestMembersCount + otherStaffCount
        self.bandMembersCount = bandMembersCount
        self.bandMembers = release.bandMembers
        self.guestMembersCount = guestMembersCount
        self.guestMembers = release.guestMembers
        self.otherStaffCount = otherStaffCount
        self.otherStaff = release.otherStaff

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
        case .complete: return completeCount
        case .bandMembers: return bandMembersCount
        case .guestMembers: return guestMembersCount
        case .otherStaff: return otherStaffCount
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
