//
//  Genre.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 21/06/2021.
//

import Foundation

public enum Genre: String, Sendable, CaseIterable {
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

    public var parameterString: String {
        switch self {
        case .black:
            "black"
        case .death:
            "death"
        case .doomStonerSludge:
            "doom"
        case .electronicIndustrial:
            "electronic"
        case .experimentalAvantGarde:
            "avantgarde"
        case .folkVikingPagan:
            "folk"
        case .gothic:
            "gothic"
        case .grindcore:
            "grind"
        case .groove:
            "groove"
        case .heavy:
            "heavy"
        case .metalcoreDeathcore:
            "metalcore"
        case .power:
            "power"
        case .progressive:
            "prog"
        case .speed:
            "speed"
        case .symphonic:
            "orchestral"
        case .thrash:
            "thrash"
        }
    }
}
