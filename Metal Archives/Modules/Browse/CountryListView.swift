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
        case .bands:
            "Bands by country"
        case .labels:
            "Labels by country"
        }
    }
}

struct CountryListView: View {
    let mode: CountryListMode
    @Binding var path: NavigationPath

    var body: some View {
        Form {
            ForEach(CountryManager.shared.countries, id: \.isoCode) { country in
                NavigationLink(destination: {
                    switch mode {
                    case .bands:
                        BandsByCountryView(country: country, path: $path)
                    case .labels:
                        LabelsByCountryView(country: country, path: $path)
                    }
                }, label: {
                    Text(country.nameAndFlag)
                })
            }
        }
        .navigationTitle(mode.navigationTitle)
    }
}

#Preview {
    NavigationView {
        CountryListView(mode: .bands, path: .constant(.init()))
    }
    .environment(\.colorScheme, .dark)
    .environmentObject(Preferences())
}
