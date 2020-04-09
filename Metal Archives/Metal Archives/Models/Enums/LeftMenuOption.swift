//
//  LeftMenuOption.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 09/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

enum LeftMenuOption {
    case homepage, bandByAphabetical, bandByCountry, bandByGenre, labelByAlphabetical, labelByCountry, rip, randomBand, settings, about
    
    var iconName: String {
        switch self {
        case .homepage: return Ressources.Images.homeIcon
        case .bandByAphabetical: return Ressources.Images.alphabeticalIcon
        case .bandByCountry: return Ressources.Images.countryIcon
        case .bandByGenre: return Ressources.Images.genreIcon
        case .labelByAlphabetical: return Ressources.Images.alphabeticalIcon
        case .labelByCountry: return Ressources.Images.countryIcon
        case .rip: return Ressources.Images.ripIcon
        case .randomBand: return Ressources.Images.randomIcon
        case .settings: return Ressources.Images.settingsIcon
        case .about: return Ressources.Images.aboutIcon
        }
    }
    
    var title: String {
        switch self {
        case .homepage: return "Alphabetical"
        case .bandByAphabetical: return "Alphabetical"
        case .bandByCountry: return "Country"
        case .bandByGenre: return "Genre"
        case .labelByAlphabetical: return "Alphabetical"
        case .labelByCountry: return "Country"
        case .rip: return "R.I.P"
        case .randomBand: return "Random Band"
        case .settings: return "Settings"
        case .about: return "About"
        }
    }
}
