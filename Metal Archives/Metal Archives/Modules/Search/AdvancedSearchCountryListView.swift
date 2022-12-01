//
//  AdvancedSearchCountryListView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/06/2021.
//

import SwiftUI

struct AdvancedSearchCountryListView: View {
    @ObservedObject var countrySet: CountrySet

    var body: some View {
        Form {
            ForEach(CountryManager.shared.countries, id: \.isoCode) { country in
                HStack {
                    Text(country.nameAndFlag)
                    Spacer()
                    if countrySet.isSelected(country) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture { countrySet.select(country) }
            }
        }
        .toolbar { toolbarContent }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(countrySet.title)
                .fontWeight(.bold)
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            if !countrySet.noChoice {
                Button(action: countrySet.deselectAll) {
                    Text("Deselect all")
                }
            }
        }
    }
}

struct AdvancedSearchCountryListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AdvancedSearchCountryListView(countrySet: .init())
        }
        .environment(\.colorScheme, .dark)
        .environmentObject(Preferences())
    }
}
