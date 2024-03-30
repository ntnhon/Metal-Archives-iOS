//
//  AdvancedSearchAlbumsView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/06/2021.
//

import SwiftUI

private let kStartDate = DateFormatter.default.date(from: "1960-01-01 00:00:00") ?? Date()

struct AdvancedSearchAlbumsView: View {
    @EnvironmentObject private var preferences: Preferences
    @State private var bandName = ""
    @State private var exactMatchBandName = false
    @State private var releaseTitle = ""
    @State private var exactMatchReleaseTitle = false
    @State private var fromDate = kStartDate
    @State private var toDate = Date()
    @State private var location = ""
    @State private var label = ""
    @State private var indieLabel = false
    @State private var catalogNumber = ""
    @State private var identifier = ""
    @State private var recordingInformation = ""
    @State private var versionDescription = ""
    @State private var additionalNote = ""
    @State private var genre = ""
    @StateObject private var countrySet = CountrySet()
    @StateObject private var releaseTypeSet = ReleaseTypeSet()
    @StateObject private var releaseFormatSet = ReleaseFormatSet()
    let apiService: APIServiceProtocol

    var body: some View {
        Form {
            Section(content: {
                HStack {
                    Text("Name")
                    TextField("", text: $bandName)
                        .textFieldStyle(.roundedBorder)
                }

                Toggle("Exact match band name", isOn: $exactMatchBandName)

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
                    Text("Location")
                    TextField("City / state / province", text: $location)
                        .textFieldStyle(.roundedBorder)
                }
            }, header: {
                Text("Band")
            })

            Section(content: {
                HStack {
                    Text("Title")
                    TextField("", text: $releaseTitle)
                        .textFieldStyle(.roundedBorder)
                }

                Toggle("Exact match release title", isOn: $exactMatchReleaseTitle)

                VStack(alignment: .leading) {
                    Text("Release date:")

                    HStack {
                        Text("From")

                        DatePicker("",
                                   selection: $fromDate,
                                   in: kStartDate...Date(),
                                   displayedComponents: [.date])
                            .labelsHidden()

                        Text("to")

                        DatePicker("",
                                   selection: $toDate,
                                   in: kStartDate...Date(),
                                   displayedComponents: [.date])
                            .labelsHidden()
                    }
                }

                NavigationLink(destination: ReleaseTypeListView(releaseTypeSet: releaseTypeSet)) {
                    HStack {
                        Text("Release type")
                        Spacer()
                        Text(releaseTypeSet.detail)
                            .font(.callout)
                            .foregroundColor(.gray)
                    }
                }

                NavigationLink(destination: ReleaseFormatListView(releaseFormatSet: releaseFormatSet)) {
                    HStack {
                        Text("Release format")
                        Spacer()
                        Text(releaseFormatSet.detail)
                            .font(.callout)
                            .foregroundColor(.gray)
                    }
                }
            }, header: {
                Text("Release")
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
                    Text("Catalog number")
                    TextField("", text: $catalogNumber)
                        .textFieldStyle(.roundedBorder)
                }

                HStack {
                    Text("Identifier")
                    TextField("barcode, matrix, etc.", text: $identifier)
                        .textFieldStyle(.roundedBorder)
                }

                HStack {
                    Text("Recording information")
                    TextField("studio, city, etc.", text: $recordingInformation)
                        .textFieldStyle(.roundedBorder)
                }

                HStack {
                    Text("Version description")
                    TextField("country, digipak, etc.", text: $versionDescription)
                        .textFieldStyle(.roundedBorder)
                }

                HStack {
                    Text("Additional note")
                    TextField("", text: $additionalNote)
                        .textFieldStyle(.roundedBorder)
                }

                HStack {
                    Text("Genre")
                    TextField("", text: $genre)
                        .textFieldStyle(.roundedBorder)
                }
            }, header: {
                Text("Additional information")
            })

            Section {
                NavigationLink(
                    destination: {
                        AdvancedSearchResultView(viewModel: .init(apiService: apiService,
                                                                  manager: makePageManager()))
                    },
                    label: {
                        Text("SEARCH")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                    })
            }
            .listRowBackground(Color.accentColor)
        }
        .tint(preferences.theme.primaryColor)
        .navigationBarTitle("Advanced search albums", displayMode: .large)
    }

    private func makePageManager() -> ReleaseAdvancedSearchResultPageManager {
        let params = ReleaseAdvancedSearchParams()
        params.bandName = bandName
        params.exactMatchBandName = exactMatchBandName
        params.releaseTitle = releaseTitle
        params.exactMatchReleaseTitle = exactMatchReleaseTitle
        params.fromDate = fromDate
        params.toDate = toDate
        params.countries = countrySet.choices
        params.location = location
        params.label = label
        params.indieLabel = indieLabel
        params.catalogNumber = catalogNumber
        params.identifier = identifier
        params.recordingInformation = recordingInformation
        params.versionDescription = versionDescription
        params.additionalNote = additionalNote
        params.genre = genre
        params.releaseTypes = releaseTypeSet.choices
        params.releaseFormats = releaseFormatSet.choices
        return .init(apiService: apiService, params: params)
    }
}

struct AdvancedSearchAlbumsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AdvancedSearchAlbumsView(apiService: APIService())
        }
        .environment(\.colorScheme, .dark)
        .environmentObject(Preferences())
    }
}
