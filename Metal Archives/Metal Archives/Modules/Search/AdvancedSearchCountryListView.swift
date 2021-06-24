//
//  AdvancedSearchCountryListView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/06/2021.
//

import SwiftUI

struct AdvancedSearchCountryListView: View {
    @ObservedObject var countrySet: CountrySet
    @State private var navigationTitle = "Any country"

    var body: some View {
        List {
            ForEach(CountryManager.shared.countries, id: \.isoCode) { country in
                HStack {
                    Button(action: {
                        handleSelection(country)
                    }, label: {
                        Text(country.nameAndFlag)
                    })
                    .foregroundColor(.primary)

                    if countrySet.countries.contains(country) {
                        Spacer()

                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle(navigationTitle, displayMode: .inline)
        .navigationBarItems(trailing:
                                Button(action: {
                                    countrySet.countries.removeAll()
                                    updateNavigationTitle()
                                }, label: {
                                    Text("Deselect all")
                                }))
        .onAppear {
            updateNavigationTitle()
        }
    }

    private func handleSelection(_ country: Country) {
        if countrySet.countries.contains(country) {
            countrySet.countries.removeAll { $0 == country }
        } else {
            countrySet.countries.append(country)
        }
        updateNavigationTitle()
    }

    private func updateNavigationTitle() {
        if countrySet.countries.isEmpty {
            navigationTitle = "Any country"
        } else if countrySet.countries.count == 1 {
            navigationTitle = "1 country selected"
        } else {
            navigationTitle = "\(countrySet.countries.count) countries selected"
        }
    }
}

struct AdvancedSearchCountryListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AdvancedSearchCountryListView(countrySet: .init())
        }
    }
}
