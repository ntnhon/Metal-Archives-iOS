//
//  Preferences.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 20/06/2021.
//

import SwiftUI

final class Preferences: ObservableObject {
    @AppStorage("discographyMode") var discographyMode: DiscographyMode = .complete
    @AppStorage("homeSectionOrder") var homeSectionOrder: [HomeSection] =
        [.upcomingAlbums, .latestAdditions, .latestUpdates, .latestReviews]
    @AppStorage("showThumbnails") var showThumbnails = true
    @AppStorage("useHaptic") var useHaptic = true
    @AppStorage("theme") var theme: Theme = .default
}
