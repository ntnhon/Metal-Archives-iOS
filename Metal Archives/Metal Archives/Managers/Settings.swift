//
//  Settings.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 20/06/2021.
//

import SwiftUI

final class Settings: ObservableObject {
    @AppStorage("discographyMode") var discographyMode: DiscographyMode = .complete
    @AppStorage("homeSectionOrder") var homeSectionOrder: [HomeSection] =
        [.stats, .upcomingAlbums, .latestAdditions, .latestUpdates, .latestReviews, .news]
    @AppStorage("showThumbnails") var showThumbnails = true
    @AppStorage("useHaptic") var useHaptic = true
    @AppStorage("theme") var theme: Theme = .default
}
