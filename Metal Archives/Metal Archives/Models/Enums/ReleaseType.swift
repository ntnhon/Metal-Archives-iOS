//
//  ReleaseType.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 16/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

enum ReleaseType: Int, CustomStringConvertible, CaseIterable {
    case fullLength = 1, liveAlbum = 2, demo = 3, single = 4, ep = 5, video = 6, boxedSet = 7, split = 8, compilation = 10, splitVideo = 12, collaboration = 13
    
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
    
    init?(typeString: String?) {
        guard let `typeString` = typeString else {
            return nil
        }
        
        let uppercasedTypeString = typeString.uppercased()
        
        if uppercasedTypeString == "Full-length".uppercased() {
            self = .fullLength
        } else if uppercasedTypeString == "Live album".uppercased() {
            self = .liveAlbum
        } else if uppercasedTypeString == "Demo".uppercased() {
            self = .demo
        } else if uppercasedTypeString == "Single".uppercased() {
            self = .single
        } else if uppercasedTypeString == "EP" {
            self = .ep
        } else if uppercasedTypeString == "Video".uppercased() {
            self = .video
        } else if uppercasedTypeString == "Boxed set".uppercased() {
            self = .boxedSet
        } else if uppercasedTypeString == "Split".uppercased() {
            self = .split
        } else if uppercasedTypeString == "Compilation".uppercased() {
            self = .compilation
        } else if uppercasedTypeString == "Split video".uppercased() {
            self = .splitVideo
        } else if uppercasedTypeString == "Collaboration".uppercased() {
            self = .collaboration
        } else {
            return nil
        }
    }
}
