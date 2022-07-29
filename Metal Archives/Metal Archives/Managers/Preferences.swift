//
//  Preferences.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 20/06/2021.
//

import SwiftUI

final class Preferences: ObservableObject {
    @AppStorage("discographyMode")
    var discographyMode: DiscographyMode = .complete

    @AppStorage("dateOrder")
    var dateOrder: Order = .ascending

    @AppStorage("homeSectionOrder")
    var homeSectionOrder: [HomeSection] = [.upcomingAlbums, .latestAdditions, .latestUpdates, .latestReviews]

    @AppStorage("showThumbnails")
    var showThumbnails = true

    @AppStorage("useHaptic")
    var useHaptic = true

    @AppStorage("theme")
    var theme: Theme = .default {
        didSet {
            updateUIAlertControllerAppearance()
        }
    }

    init() {
        updateUIAlertControllerAppearance()
    }

    private func updateUIAlertControllerAppearance() {
        guard let cgColor = theme.primaryColor.cgColor else { return }
        // swiftlint:disable:next line_length
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(cgColor: cgColor)
    }
}
