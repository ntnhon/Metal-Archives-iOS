//
//  DiscographyViewModel.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 08/07/2021.
//

import Combine
import SwiftUI

final class DiscographyViewModel: ObservableObject {
    @Published var selectedMode: DiscographyMode { didSet { updateReleases() } }
    @Published var selectedOrder: Order { didSet { updateReleases() } }
    @Published private(set) var releases = [ReleaseInBand]()
    private let discography: Discography
    private let main: [ReleaseInBand]
    private let lives: [ReleaseInBand]
    private let demos: [ReleaseInBand]
    private let misc: [ReleaseInBand]
    let modes: [DiscographyMode]

    init(discography: Discography,
         discographyMode: DiscographyMode,
         order: Order)
    {
        self.discography = discography
        selectedMode = discographyMode
        selectedOrder = order
        main = discography.releases.filter { $0.type == .fullLength }
        let livesTypes: [ReleaseType] = [.liveAlbum, .video, .splitVideo]
        lives = discography.releases.filter { livesTypes.contains($0.type) }
        demos = discography.releases.filter { $0.type == .demo }
        let notMiscTypes: [ReleaseType] = [.fullLength, .liveAlbum, .video, .splitVideo, .demo]
        misc = discography.releases.filter { !notMiscTypes.contains($0.type) }

        var modes: [DiscographyMode] = []
        let nonEmptyModeCount = [main, lives, demos, misc].reduce(0) { $0 + (!$1.isEmpty ? 1 : 0) }
        if nonEmptyModeCount > 1 { modes.append(.complete) }
        if !main.isEmpty { modes.append(.main) }
        if !lives.isEmpty { modes.append(.lives) }
        if !demos.isEmpty { modes.append(.demos) }
        if !misc.isEmpty { modes.append(.misc) }
        self.modes = modes.reversed()
        updateReleases()
    }

    func title(for mode: DiscographyMode) -> String {
        let count: Int
        switch mode {
        case .complete:
            count = discography.releases.count
        case .main:
            count = main.count
        case .lives:
            count = lives.count
        case .demos:
            count = demos.count
        case .misc:
            count = misc.count
        }
        return "\(mode.description) (\(count))"
    }

    private func updateReleases() {
        switch selectedMode {
        case .complete:
            releases = discography.releases.sorted(by: selectedOrder)
        case .main:
            releases = main.sorted(by: selectedOrder)
        case .lives:
            releases = lives.sorted(by: selectedOrder)
        case .demos:
            releases = demos.sorted(by: selectedOrder)
        case .misc:
            releases = misc.sorted(by: selectedOrder)
        }
    }
}

extension Array where Element == ReleaseInBand {
    func sorted(by order: Order) -> [ReleaseInBand] {
        switch order {
        case .ascending:
            sorted { $0.year < $1.year }
        case .descending:
            sorted { $0.year > $1.year }
        }
    }
}
