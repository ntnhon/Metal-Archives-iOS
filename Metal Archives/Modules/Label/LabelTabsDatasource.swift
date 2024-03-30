//
//  LabelTabsDatasource.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 05/11/2022.
//

import Foundation

enum LabelTab {
    case subLabels
    case currentRoster
    case lastKnownRoster
    case pastRoster
    case releases
    case additionalNotes
    case links

    var title: String {
        switch self {
        case .subLabels:
            "Sub-labels"
        case .currentRoster:
            "Current roster"
        case .lastKnownRoster:
            "Last known roster"
        case .pastRoster:
            "Past roster"
        case .releases:
            "Releases"
        case .additionalNotes:
            "Additional notes"
        case .links:
            "Links"
        }
    }

    var iconName: String {
        switch self {
        case .subLabels:
            "tag"
        case .currentRoster, .lastKnownRoster:
            "circle"
        case .pastRoster:
            "circle.dashed"
        case .releases:
            "opticaldisc"
        case .additionalNotes:
            "info.circle"
        case .links:
            "link"
        }
    }

    var selectedIconName: String {
        switch self {
        case .subLabels:
            "tag.fill"
        case .currentRoster, .lastKnownRoster:
            "circle.fill"
        case .pastRoster:
            "circle.dashed.inset.filled"
        case .releases:
            "opticaldisc.fill"
        case .additionalNotes:
            "info.circle.fill"
        case .links:
            "link"
        }
    }
}

final class LabelTabsDatasource: HorizontalTabsDatasource {
    private let allTabs: [LabelTab]
    private(set) var selectedTab: LabelTab {
        didSet {
            objectWillChange.send()
        }
    }

    init(label: LabelDetail) {
        var allTabs = [LabelTab]()
        if !label.subLabels.isEmpty {
            allTabs.append(.subLabels)
        }

        if label.isLastKnown {
            allTabs.append(.lastKnownRoster)
        } else {
            allTabs.append(.currentRoster)
        }

        allTabs.append(.pastRoster)
        allTabs.append(.releases)

        if label.additionalNotes != nil {
            allTabs.append(.additionalNotes)
        }

        allTabs.append(.links)
        self.allTabs = allTabs
        selectedTab = allTabs.first ?? .links
    }

    override func numberOfTabs() -> Int {
        allTabs.count
    }

    override func titleForTab(index: Int) -> String {
        allTabs[index].title
    }

    override func normalSystemIconNameForTab(index: Int) -> String {
        allTabs[index].iconName
    }

    override func selectedSystemIconNameForTab(index: Int) -> String {
        allTabs[index].selectedIconName
    }

    override func isSelectedTab(index: Int) -> Bool {
        let tab = allTabs[index]
        return tab == selectedTab
    }

    override func onSelectTab(index: Int) {
        selectedTab = allTabs[index]
    }
}
