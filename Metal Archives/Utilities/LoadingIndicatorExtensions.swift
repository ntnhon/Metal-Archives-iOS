//
//  LoadingIndicatorExtensions.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 01/04/2024.
//

import SwiftfulLoadingIndicators

extension LoadingIndicator.LoadingAnimation {
    var title: String {
        switch self {
        case .threeBalls:
            "Three balls"
        case .threeBallsRotation:
            "Three balls rotation"
        case .threeBallsBouncing:
            "Three balls bouncing"
        case .threeBallsTriangle:
            "Three balls triangle"
        case .fiveLines:
            "Five lines"
        case .fiveLinesChronological:
            "Five lines chronological"
        case .fiveLinesWave:
            "Five lines wave"
        case .fiveLinesCenter:
            "Five lines center"
        case .fiveLinesPulse:
            "Five lines pulse"
        case .pulse:
            "Pulse"
        case .pulseOutline:
            "Pulse outline"
        case .pulseOutlineRepeater:
            "Pulse outline repeater"
        case .circleTrim:
            "Circle trim"
        case .circleRunner:
            "Circle runner"
        case .circleBlinks:
            "Circle blinks"
        case .circleBars:
            "Circle bars"
        case .doubleHelix:
            "Double helix"
        case .bar:
            "Bar"
        case .barStripes:
            "Bar stripes"
        case .text:
            "Text"
        case .heart:
            "Heart"
        }
    }
}
