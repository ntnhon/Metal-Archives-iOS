//
//  AdvancedSearchBandsView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/06/2021.
//

import SwiftUI

private let kMinYear = 1960
private let kThisYear = Calendar.current.component(.year, from: .init())

struct AdvancedSearchBandsView: View {
    @EnvironmentObject private var preferences: Preferences
    @State private var bandName = ""
    @State private var exactMatch = false
    @State private var genre = ""
    @StateObject private var countrySet = CountrySet()
    @State private var fromYear = kMinYear
    @State private var toYear = kThisYear
    @State private var additionalNote = ""
    @StateObject private var bandStatusSet = BandStatusSet()
    @State private var lyricalThemes = ""
    @State private var location = ""
    @State private var label = ""
    @State private var indieLabel = false

    var body: some View {
        Form {
            Section(content: {
                HStack {
                    Text("Name")
                    TextField("", text: $bandName)
                        .textFieldStyle(.roundedBorder)
                }

                Toggle("Exact match band name", isOn: $exactMatch)

                NavigationLink(destination: AdvancedSearchCountryListView(countrySet: countrySet)) {
                    HStack {
                        Text("Country")
                        Spacer()
                        Text(countrySet.detail)
                            .font(.callout)
                            .foregroundColor(.gray)
                    }
                }

                HStack {
                    Text("Year of formation:")
                    YearPicker(selectedYear: $fromYear)
                    Image(systemName: "arrow.right")
                        .controlSize(.small)
                    YearPicker(selectedYear: $toYear)
                }

                NavigationLink(destination: BandStatusListView(bandStatusSet: bandStatusSet)) {
                    HStack {
                        Text("Status")
                        Spacer()
                        Text(bandStatusSet.detail)
                            .font(.callout)
                            .foregroundColor(.gray)
                    }
                }
            }, header: {
                Text("Band")
            })

            Section(content: {
                HStack {
                    Text("Name")
                    TextField("", text: $label)
                        .textFieldStyle(.roundedBorder)
                }

                Toggle("Indie label", isOn: $indieLabel)
            }, header: {
                Text("Label")
            })

            Section(content: {
                HStack {
                    Text("Genre")
                    TextField("", text: $genre)
                        .textFieldStyle(.roundedBorder)
                }

                HStack {
                    Text("Additional note")
                    TextField("", text: $additionalNote)
                        .textFieldStyle(.roundedBorder)
                }

                HStack {
                    Text("Lyrical theme(s)")
                    TextField("", text: $lyricalThemes)
                        .textFieldStyle(.roundedBorder)
                }

                HStack {
                    Text("Location")
                    TextField("City / state / province", text: $location)
                        .textFieldStyle(.roundedBorder)
                }
            }, header: {
                Text("Additional information")
            })

            Section {
                NavigationLink(
                    destination: {
                        AdvancedSearchResultView(viewModel: .init(manager: makePageManager()))
                    },
                    label: {
                        Text("SEARCH")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                )
            }
            .listRowBackground(Color.accentColor)
        }
        .tint(preferences.theme.primaryColor)
        .navigationBarTitle("Advanced search bands", displayMode: .large)
    }

    private func makePageManager() -> BandAdvancedSearchResultPageManager {
        let params = BandAdvancedSearchParams()
        params.bandName = bandName
        params.exactMatch = exactMatch
        params.genre = genre
        params.countries = countrySet.choices
        params.fromYear = fromYear
        params.toYear = toYear
        params.notes = additionalNote
        params.statuses = bandStatusSet.choices
        params.lyricalThemes = lyricalThemes
        params.location = location
        params.labelName = label
        params.indieLabel = indieLabel
        return .init(params: params)
    }
}

private struct YearPicker: View {
    @EnvironmentObject private var preferences: Preferences
    @Binding var selectedYear: Int

    var body: some View {
        Menu(content: {
            ForEach((kMinYear ... kThisYear).reversed(), id: \.self) { year in
                Button(action: {
                    selectedYear = year
                }, label: {
                    Label(title: {
                        Text(String(format: "%0d", year))
                    }, icon: {
                        if year == selectedYear {
                            Image(systemName: "checkmark")
                        }
                    })
                })
            }
        }, label: {
            HStack {
                Text(String(format: "%0d", selectedYear))
                Image(systemName: "chevron.down")
                    .imageScale(.small)
            }
            .transaction { transaction in
                transaction.animation = nil
            }
            .padding(8)
            .background(preferences.theme.primaryColor)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        })
    }
}

#Preview {
    NavigationView {
        AdvancedSearchBandsView()
            .environmentObject(Preferences())
    }
    .environment(\.colorScheme, .dark)
    .environmentObject(Preferences())
}
