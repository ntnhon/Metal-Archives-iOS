//
//  ReleaseType.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

import Combine

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
        case .single: return "Single"
        case .fullLength: return "Full-length"
        case .video: return "Video"
        case .liveAlbum: return "Live album"
        case .split: return "Split"
        case .ep: return "EP"
        case .compilation: return "Compilation"
        case .demo: return "Demo"
        case .boxedSet: return "Boxed set"
        case .splitVideo: return "Split video"
        case .collaboration: return "Collaboration"
        }
    }

    init?(typeString: String) {
        switch typeString.lowercased() {
        case "full-length": self = .fullLength
        case "live album": self = .liveAlbum
        case "demo": self = .demo
        case "single": self = .single
        case "ep": self = .ep
        case "video": self = .video
        case "boxed set": self = .boxedSet
        case "split": self = .split
        case "compilation": self = .compilation
        case "split video": self = .splitVideo
        case "collaboration": self = .collaboration
        default: return nil
        }
    }
}

final class ReleaseTypeSet: ObservableObject {
    @Published var types: [ReleaseType] = []
}
