//
//  ArtistLiteInRelease.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 05/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class ArtistLiteInRelease: ThumbnailableObject {
    let name: String
    let additionalDetail: String?
    let lineUpType: LineUpType
    let instrumentString: String
    let bandName: String?
    
    init?(name: String, urlString: String, additionalDetail: String?, instrumentString: String, lineUpType: LineUpType, bandName: String? = nil) {
        self.name = name
        self.additionalDetail = additionalDetail
        self.instrumentString = instrumentString
        self.lineUpType = lineUpType
        self.bandName = bandName
        
        super.init(urlString: urlString, imageType: .artist)
    }
}
