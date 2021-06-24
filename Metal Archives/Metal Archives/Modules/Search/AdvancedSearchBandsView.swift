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
            Section(header: Text("Band")) {
                TextField("Band name", text: $bandName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Toggle("Exact match band name", isOn: $exactMatch)

                NavigationLink(destination: AdvancedSearchCountryListView(countrySet: countrySet)) {
                    HStack {
                        Text("Country")
                        Spacer()
                        Text(countrySet.detailString)
                            .font(.callout)
                            .foregroundColor(.gray)
                    }
                }

                HStack {
                    Text("Year of formation from ")

                    Picker(selection: $fromYear,
                           label: Text(String(format: "%0d", fromYear))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(4)
                            .background(Color.accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 4))) {
                        ForEach((1_960...kThisYear).reversed(), id: \.self) {
                            Text(String(format: "%0d", $0))
                                .tag($0)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())

                    Text("to")

                    Picker(selection: $toYear,
                           label: Text(String(format: "%0d", toYear))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(4)
                            .background(Color.accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 4))) {
                        ForEach((1_960...kThisYear).reversed(), id: \.self) {
                            Text(String(format: "%0d", $0))
                                .tag($0)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }

                NavigationLink(destination: BandStatusListView(bandStatusSet: bandStatusSet)) {
                    HStack {
                        Text("Status")
                        Spacer()
                        Text(bandStatusSet.detailString)
                            .font(.callout)
                            .foregroundColor(.gray)
                    }
                }
            }

            Section(header: Text("Label")) {
                TextField("Label name", text: $label)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Toggle("Indie label", isOn: $indieLabel)
            }

            Section(header: Text("Additional information")) {
                TextField("Genre", text: $genre)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Additional note", text: $additionalNote)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Lyrical theme(s)", text: $lyricalThemes)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("City / state / province", text: $cityStateProvince)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            Section {
                HStack {
                    Spacer()
                    Button(action: {}, label: {
                        Text("SEARCH")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    })
                    Spacer()
                }
            }
            .listRowBackground(Color.accentColor)
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle("Advanced search bands", displayMode: .inline)
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
