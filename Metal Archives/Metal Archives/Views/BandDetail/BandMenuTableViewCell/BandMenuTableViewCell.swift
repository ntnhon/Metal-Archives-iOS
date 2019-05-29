//
//  BandMenuTableViewCell.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 29/05/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit

enum BandMenuOption: Int, CustomStringConvertible, CaseIterable {
    case discography = 0, members, reviews, similarArtists, about, relatedLinks
    
    var description: String {
        switch self {
        case .discography: return "Discography"
        case .members: return "Members"
        case .reviews: return "Reviews"
        case .similarArtists: return "Similar Artists"
        case .about: return "About"
        case .relatedLinks: return "Related Links"
        }
    }
}

final class BandMenuTableViewCell: BaseTableViewCell, RegisterableCell {
    private(set) var horizontalMenuView: HorizontalMenuView!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = Settings.currentTheme.backgroundColor
        
        let bandMenuOptionStrings = BandMenuOption.allCases.map({return $0.description})
        horizontalMenuView = HorizontalMenuView(options: bandMenuOptionStrings, font: Settings.currentFontSize.secondaryTitleFont, normalColor: Settings.currentTheme.bodyTextColor, highlightColor: Settings.currentTheme.secondaryTitleColor)
        horizontalMenuView.backgroundColor = Settings.currentTheme.backgroundColor
        addSubview(horizontalMenuView)
        
        horizontalMenuView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            horizontalMenuView.topAnchor.constraint(equalTo: topAnchor),
            horizontalMenuView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            horizontalMenuView.bottomAnchor.constraint(equalTo: bottomAnchor),
            horizontalMenuView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 10),
            horizontalMenuView.heightAnchor.constraint(equalToConstant: horizontalMenuView.intrinsicHeight)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
