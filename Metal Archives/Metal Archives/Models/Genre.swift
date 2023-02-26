//
//  Genre.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 21/06/2021.
//

import Foundation

enum Genre: String, CaseIterable {
    case black = "Black"
    case death = "Death"
    case doomStonerSludge = "Doom / Stoner / Sludge"
    case electronicIndustrial = "Electronic / Industrial"
    case experimentalAvantGarde = "Experimental / Avant-garde"
    case folkVikingPagan = "Folk / Viking / Pagan"
    case gothic = "Gothic"
    case grindcore = "Grindcore"
    case groove = "Groove"
    case heavy = "Heavy"
    case metalcoreDeathcore = "Metalcore / Deathcore"
    case power = "Power"
    case progressive = "Progressive"
    case speed = "Speed"
    case symphonic = "Symphonic"
    case thrash = "Thrash"

    var parameterString: String {
        switch self {
        case .black: return "black"
        case .death: return "death"
        case .doomStonerSludge: return "doom"
        case .electronicIndustrial: return "electronic"
        case .experimentalAvantGarde: return "avantgarde"
        case .folkVikingPagan: return "folk"
        case .gothic: return "gothic"
        case .grindcore: return "grind"
        case .groove: return "groove"
        case .heavy: return "heavy"
        case .metalcoreDeathcore: return "metalcore"
        case .power: return "power"
        case .progressive: return "prog"
        case .speed: return "speed"
        case .symphonic: return "orchestral"
        case .thrash: return "thrash"
        }
    }
}
