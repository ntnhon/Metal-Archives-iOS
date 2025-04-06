//
//  ReleaseType.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

import Foundation

public enum ReleaseType: Int, Sendable, CustomStringConvertible, CaseIterable {
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

    public var description: String {
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
}
