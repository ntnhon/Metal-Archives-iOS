//
//  DiscographyViewModel.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 08/07/2021.
//

import Combine

final class DiscographyViewModel: ObservableObject {
    private let discography: Discography
    private let main: [ReleaseInBand]
    private let lives: [ReleaseInBand]
    private let demos: [ReleaseInBand]
    private let misc: [ReleaseInBand]
    let modes: [DiscographyMode]

    init(discography: Discography) {
        self.discography = discography
        self.main = discography.releases.filter { $0.type == .fullLength }
        self.lives = discography.releases.filter { $0.type == .liveAlbum }
        self.demos = discography.releases.filter { $0.type == .demo }
        let notMiscTypes: [ReleaseType] = [.fullLength, .liveAlbum, .demo]
        self.misc = discography.releases.filter { notMiscTypes.contains($0.type) }

        var modes: [DiscographyMode] = []
        let nonEmptyModeCount = [main, lives, demos, misc].reduce(0) { $0 + (!$1.isEmpty ? 1 : 0) }
        if nonEmptyModeCount > 1 { modes.append(.complete) }
        if !main.isEmpty { modes.append(.main) }
        if !lives.isEmpty { modes.append(.lives) }
        if !demos.isEmpty { modes.append(.demos) }
        if !misc.isEmpty { modes.append(.misc) }
        self.modes = modes.reversed()
    }

    func title(for mode: DiscographyMode) -> String {
        let count: Int
        switch mode {
        case .complete: count = discography.releases.count
        case .main: count = main.count
        case .lives: count = lives.count
        case .demos: count = demos.count
        case .misc: count = misc.count
        }

        let releaseCountString = "(\(count) release\(count > 1 ? "s" : ""))"
        return mode.description + " " + releaseCountString
    }
}
