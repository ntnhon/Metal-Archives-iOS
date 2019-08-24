//
//  Genre.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 16/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

enum Genre: Int, CustomStringConvertible, CaseIterable {
    case black = 0
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
    
    var upcomingAlbumPredicate: NSPredicate {
        switch self {
        case .black: return NSPredicate(format: "self.genre CONTAINS[cd] 'black'")
        case .death: return NSPredicate(format: "genre CONTAINS[cd] 'death'")
        case .doomStonerSludge: return NSPredicate(format: "genre CONTAINS[cd] 'doom' || genre CONTAINS[cd] 'stoner' || genre CONTAINS[cd] 'sludge'")
        case .electronicIndustrial: return NSPredicate(format: "genre CONTAINS[cd] 'electronic' || genre CONTAINS[cd] 'industrial'")
        case .experimentalAvantGarde: return NSPredicate(format: "genre CONTAINS[cd] 'experimental' || genre CONTAINS[cd] 'avant-garde'")
        case .folkVikingPagan: return NSPredicate(format: "genre CONTAINS[cd] 'folk' || genre CONTAINS[cd] 'viking' || genre CONTAINS[cd] 'pagan'")
        case .gothic: return NSPredicate(format: "genre CONTAINS[cd] 'gothic'")
        case .grindcore: return NSPredicate(format: "genre CONTAINS[cd] 'grindcore'")
        case .groove: return NSPredicate(format: "genre CONTAINS[cd] 'groove'")
        case .heavy: return NSPredicate(format: "genre CONTAINS[cd] 'heavy'")
        case .metalcoreDeathcore: return NSPredicate(format: "genre CONTAINS[cd] 'metalcore' || genre CONTAINS[cd] 'deathcore'")
        case .power: return NSPredicate(format: "genre CONTAINS[cd] 'power'")
        case .progressive: return NSPredicate(format: "genre CONTAINS[cd] 'progressive'")
        case .speed: return NSPredicate(format: "genre CONTAINS[cd] 'speed'")
        case .symphonic: return NSPredicate(format: "genre CONTAINS[cd] 'symphonic'")
        case .thrash: return NSPredicate(format: "genre CONTAINS[cd] 'thrash'")
        }
    }
}
