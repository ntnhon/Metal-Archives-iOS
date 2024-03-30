//
//  ReleaseType.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

import Combine
import SwiftUI

enum ReleaseType: Int, CustomStringConvertible, CaseIterable {
    case fullLength = 1
    case liveAlbum = 2
    case demo = 3
    case single = 4
    case ep = 5
    case video = 6
    case boxedSet = 7
    case split = 8
    case compilation = 10
    case splitVideo = 12
    case collaboration = 13

    var description: String {
        switch self {
        case .single:
            "Single"
        case .fullLength:
            "Full-length"
        case .video:
            "Video"
        case .liveAlbum:
            "Live album"
        case .split:
            "Split"
        case .ep:
            "EP"
        case .compilation:
            "Compilation"
        case .demo:
            "Demo"
        case .boxedSet:
            "Boxed set"
        case .splitVideo:
            "Split video"
        case .collaboration:
            "Collaboration"
        }
    }

    // swiftlint:disable cyclomatic_complexity
    init?(typeString: String) {
        switch typeString.lowercased() {
        case "full-length":
            self = .fullLength
        case "live album":
            self = .liveAlbum
        case "demo":
            self = .demo
        case "single":
            self = .single
        case "ep":
            self = .ep
        case "video":
            self = .video
        case "boxed set":
            self = .boxedSet
        case "split":
            self = .split
        case "compilation":
            self = .compilation
        case "split video":
            self = .splitVideo
        case "collaboration":
            self = .collaboration
        default:
            return nil
        }
    }

    // swiftlint:enable cyclomatic_complexity

    var titleFont: Font {
        switch self {
        case .demo:
            .callout.italic()
        case .fullLength:
            .title3.weight(.bold)
        default:
            .body
        }
    }

    func titleForegroundColor(_ theme: Theme) -> Color {
        switch self {
        case .fullLength:
            theme.primaryColor
        default:
            theme.secondaryColor
        }
    }

    var subtitleFont: Font {
        switch self {
        case .demo:
            .caption
        case .fullLength:
            .body.weight(.medium)
        default:
            .caption
        }
    }
}

extension ReleaseType: MultipleChoiceProtocol {
    static var noChoice: String { "Any type" }
    static var multipleChoicesSuffix: String { "types selected" }
    static var totalChoices: Int { ReleaseType.allCases.count }
    var choiceDescription: String { description }
}

final class ReleaseTypeSet: MultipleChoiceSet<ReleaseType>, ObservableObject {}
