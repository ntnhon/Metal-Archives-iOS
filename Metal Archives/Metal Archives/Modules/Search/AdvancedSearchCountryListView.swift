//
//  AdvancedSearchCountryListView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/06/2021.
//

import SwiftUI

struct AdvancedSearchCountryListView: View {
    @State private var selectedCountries: [Country] = []
    @State private var navigationTitle = "Any country"
    var didSelectCountries: (([Country]) -> Void)?

    var body: some View {
        Form {
            ForEach(CountryManager.shared.countries, id: \.isoCode) { country in
                HStack {
                    Button(action: {
                        handleSelection(country)
                    }, label: {
                        Text(country.nameAndFlag)
                    })
                    .foregroundColor(.primary)

                    if selectedCountries.contains(country) {
                        Spacer()

                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
            }
        }
        .navigationBarTitle(navigationTitle, displayMode: .inline)
    }

    private func handleSelection(_ country: Country) {
        if selectedCountries.contains(country) {
            selectedCountries.removeAll { $0 == country }
        } else {
            selectedCountries.append(country)
        }
        updateNavigationTitle()
        didSelectCountries?(selectedCountries)
    }

    private func updateNavigationTitle() {
        if selectedCountries.isEmpty {
            navigationTitle = "Any country"
        } else if selectedCountries.count == 1 {
            navigationTitle = "1 country selected"
        } else {
            navigationTitle = "\(selectedCountries.count) countries selected"
        }
    }
}

struct AdvancedSearchCountryListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AdvancedSearchCountryListView()
        }
    }
}
