//
//  CountryListView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 21/06/2021.
//

import SwiftUI

enum CountryListMode {
    case bands, labels

    var navigationTitle: String {
        switch self {
        case .bands: return "Bands by country"
        case .labels: return "Labels by country"
        }
    }
}

struct CountryListView: View {
    let mode: CountryListMode

    var body: some View {
        Form {
            ForEach(CountryManager.shared.countries, id: \.isoCode) { country in
                NavigationLink(destination: Text(country.nameAndFlag)) {
                    Text(country.nameAndFlag)
                }
            }
        }
        .navigationTitle(mode.navigationTitle)
    }
}

struct CountryListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CountryListView(mode: .bands)
        }
        .environment(\.colorScheme, .dark)
        .environmentObject(Preferences())
    }
}
