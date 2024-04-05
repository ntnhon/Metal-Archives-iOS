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

extension ReleaseFormat: MultipleChoiceProtocol {
    static var noChoice: String { "Any format" }
    static var multipleChoicesSuffix: String { "formats selected" }
    static var totalChoices: Int { allCases.count }
    var choiceDescription: String { rawValue }
}

final class ReleaseFormatSet: MultipleChoiceSet<ReleaseFormat>, ObservableObject {}
