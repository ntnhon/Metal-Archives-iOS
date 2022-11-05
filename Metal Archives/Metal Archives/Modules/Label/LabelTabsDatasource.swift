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
        case .subLabels: return "Sub-labels"
        case .currentRoster: return "Current roster"
        case .lastKnownRoster: return "Last known roster"
        case .pastRoster: return "Past roster"
        case .releases: return "Releases"
        case .additionalNotes: return "Additional notes"
        case .links: return "Links"
        }
    }

    var iconName: String {
        switch self {
        case .subLabels: return "tag"
        case .currentRoster, .lastKnownRoster: return "circle"
        case .pastRoster: return "circle.dashed"
        case .releases: return "circle.grid.3x3"
        case .additionalNotes: return "info.circle"
        case .links: return "link"
        }
    }

    var selectedIconName: String {
        switch self {
        case .subLabels: return "tag.fill"
        case .currentRoster, .lastKnownRoster: return "circle.fill"
        case .pastRoster: return "circle.dashed.inset.filled"
        case .releases: return "circle.grid.3x3.fill"
        case .additionalNotes: return "info.circle.fill"
        case .links: return "link"
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
        self.selectedTab = allTabs.first ?? .links
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
