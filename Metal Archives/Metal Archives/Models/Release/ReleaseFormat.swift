//
//  ReleaseFormat.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 23/06/2021.
//

import Combine

enum ReleaseFormat: String, CaseIterable {
    case cd = "CD"
    case cassette = "Cassette"
    case vinyl = "Vinyl"
    case vhs = "VHS"
    case dvd = "DVD"
    case digital = "Digital"
    case bluray = "Blu-ray"
    case other = "Other"
}

final class ReleaseFormatSet: ObservableObject {
    @Published var formats: [ReleaseFormat] = []
}
