//
//  HomeSettings.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 05/12/2022.
//

import UIKit

enum HomeSettings {
    static let entryHeight: CGFloat = 100
    static let entrySpacing: CGFloat = 8.0
    static let entryWidth: CGFloat = {
        let screenBounds = UIScreen.main.bounds
        let width = min(screenBounds.width, screenBounds.height) * 0.7
        return max(width, 350)
    }()
    static let entriesPerPage = 3
    static let pageHeight = CGFloat(entriesPerPage - 1) * entrySpacing + CGFloat(entriesPerPage) * entryHeight
}
