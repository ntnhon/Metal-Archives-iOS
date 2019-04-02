//
//  Genre.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 16/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

enum Genre: CustomStringConvertible, CaseIterable {
    case black
    case death
    case doomStonerSludge
    case electronicIndustrial
    case experimentalAvantGarde
    case folkVikingPagan
    case gothic
    case grindcore
    case groove
    case heavy
    case metalcoreDeathcore
    case power
    case progressive
    case speed
    case symphonic
    case thrash
    
    var description: String {
        switch self {
        case .black: return "Black"
        case .death: return "Death"
        case .doomStonerSludge: return "Doom/Stoner/Sludge"
        case .electronicIndustrial: return "Electronic/Industrial"
        case .experimentalAvantGarde: return "Experimental/Avant-garde"
        case .folkVikingPagan: return "Folk/Viking/Pagan"
        case .gothic: return "Gothic"
        case .grindcore: return "Grindcore"
        case .groove: return "Groove"
        case .heavy: return "Heavy"
        case .metalcoreDeathcore: return "Metalcore/Deathcore"
        case .power: return "Power"
        case .progressive: return "Progressive"
        case .speed: return "Speed"
        case .symphonic: return "Symphonic"
        case .thrash: return "Thrash"
        }
    }
    
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
