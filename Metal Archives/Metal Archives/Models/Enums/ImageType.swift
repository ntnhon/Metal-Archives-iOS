//
//  ImageType.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 16/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

enum ImageType: CustomStringConvertible {
    case bandLogo, bandPhoto, artist, release, label
    
    var description: String {
        switch self {
        case .bandLogo: return "band logo"
        case .bandPhoto: return "band photo"
        case .artist: return "artist"
        case .release: return "release"
        case .label: return "label"
        }
    }
    
    var additionString: String {
        switch self {
        case .bandLogo: return "_logo"
        case .bandPhoto: return "_photo"
        case .artist: return "_artist"
        case .release: return ""
        case .label: return "_label"
        }
    }
}
