//
//  AppVersion.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 04/04/2024.
//

import Foundation

struct NewFeature: Identifiable {
    let id = UUID().uuidString
    let title: String
    let description: String
    let systemImageName: String
}

enum AppVersion {
    case fiveDotOneDotZero

    static var current: Self { .fiveDotOneDotZero }

    var name: String {
        switch self {
        case .fiveDotOneDotZero:
            "5.1.0"
        }
    }

    // swiftlint:disable line_length
    var newFeatures: [NewFeature] {
        switch self {
        case .fiveDotOneDotZero:
            [
                .init(title: "Reliable information loading",
                      description: "No more 429 errors. You may need to wait a bit longer when loading information in some circumstances. Refer to the FAQ section to understand why.",
                      systemImageName: "info.circle"),
                .init(title: "Customizable app icon and loading indicator",
                      description: "Access 6 new app icons and 21 loading indicators. Choose your favorite one in Settings.",
                      systemImageName: "photo.circle"),
                .init(title: "Tap to see full artist's trivia",
                      description: "When viewing an artist's information, simply tap on their trivia to see it in full.",
                      systemImageName: "person.crop.circle"),
            ]
        }
    }

    // swiftlint:enable line_length
}
