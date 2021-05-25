//
//  ReleaseElement.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 24/05/2021.
//

enum ReleaseElement {
    case song(title: String, length: String, lyricId: String?, isInstrumental: Bool)
    case side(title: String)
    case disc(title: String)
    case length(title: String)
}
