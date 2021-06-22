//
//  AdvancedSearchBandsView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/06/2021.
//

import SwiftUI

private let kThisYear = Calendar.current.component(.year, from: .init())

struct AdvancedSearchBandsView: View {
    @State private var bandName = ""
    @State private var exactMatch = false
    @State private var genre = ""
    @State private var showCountryList = false
    @StateObject private var countrySet = CountrySet()
    @State private var fromYear = 1_960
    @State private var toYear = kThisYear
    @State private var additionalNote = ""
    @StateObject private var bandStatusSet = BandStatusSet()
    @State private var lyricalThemes = ""
    @State private var cityStateProvince = ""
    @State private var label = ""
    @State private var indieLabel = false

    var body: some View {
        List {
            TextField("Band name", text: $bandName)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Toggle("Exact match band name", isOn: $exactMatch)

            TextField("Genre", text: $genre)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            NavigationLink(destination: AdvancedSearchCountryListView(countrySet: countrySet)) {
                HStack {
                    Text("Country")
                    Spacer()
                    Text(countryDetailString())
                        .font(.callout)
                        .foregroundColor(.gray)
                }
            }

            HStack {
                Text("Year of formation from ")

                Picker(String(format: "%0d", fromYear), selection: $fromYear) {
                    ForEach((1_960...kThisYear).reversed(), id: \.self) {
                        Text(String(format: "%0d", $0))
                            .tag($0)
                    }
                }
                .pickerStyle(MenuPickerStyle())

                Text("to")

                Picker(String(format: "%0d", toYear), selection: $toYear) {
                    ForEach((1_960...kThisYear).reversed(), id: \.self) {
                        Text(String(format: "%0d", $0))
                            .tag($0)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }

            TextField("Additional note", text: $additionalNote)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            NavigationLink(destination: BandStatusListView(bandStatusSet: bandStatusSet)) {
                HStack {
                    Text("Status")
                    Spacer()
                    Text(statusDetailString())
                        .font(.callout)
                        .foregroundColor(.gray)
                }
            }

            Group {
                TextField("Lyrical theme(s)", text: $lyricalThemes)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("City / state / province", text: $cityStateProvince)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Label", text: $label)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Toggle("Indie label", isOn: $indieLabel)

                HStack {
                    Spacer()
                    Button(action: {}, label: {
                        Text("SEARCH")
                            .fontWeight(.bold)
                            .foregroundColor(.accentColor)
                    })
                    Spacer()
                }
            }
        }
        .navigationBarTitle("Advanced search bands", displayMode: .inline)
    }

    private func countryDetailString() -> String {
        if countrySet.countries.isEmpty {
            return "Any country"
        } else {
            return countrySet.countries.map { $0.name }.joined(separator: ", ")
        }
    }

    private func statusDetailString() -> String {
        if bandStatusSet.status.isEmpty {
            return "Any status"
        } else {
            return bandStatusSet.status.map { $0.rawValue }.joined(separator: ", ")
        }
    }
}

struct AdvancedSearchBandsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AdvancedSearchBandsView()
                .environmentObject(Preferences())
        }
    }
}
