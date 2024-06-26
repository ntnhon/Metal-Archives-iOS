//
//  CountryManager.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 21/05/2021.
//

import Foundation

struct CountryManager {
    let countries: [Country]

    private init() {
        guard let path = Bundle.main.path(forResource: "MACountries", ofType: "json"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let countriesDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        else {
            fatalError("Failed to load countries from MACountries.json")
        }

        var countries = [Country]()
        for isoCode in countriesDict.keys {
            if let countryDict = countriesDict[isoCode] as? [String: String],
               let flag = countryDict["flag"], let name = countryDict["name"]
            {
                countries.append(.init(isoCode: isoCode, flag: flag, name: name))
            } else {
                fatalError("Failed to load parse country with isoCode: \(isoCode)")
            }
        }
        self.countries = countries.sorted()
    }

    static let shared = Self()

    func country(by keyPath: KeyPath<Country, String>, value: String) -> Country {
        countries.first { $0[keyPath: keyPath] == value } ?? .unknown
    }
}
