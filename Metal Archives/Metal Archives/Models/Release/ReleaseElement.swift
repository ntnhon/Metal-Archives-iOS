//
//  ReleaseElement.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 24/05/2021.
//

struct ReleaseElement {
    enum `Type` {
        case song, side, disc, length
    }

    let title: String
    let type: Type
}
