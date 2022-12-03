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
    @State private var cityStateProvince = ""
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

    var body: some View {
        Form {
            Section(header: Text("Band")) {
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
                    Text("City/state/province")
                    TextField("", text: $cityStateProvince)
                        .textFieldStyle(.roundedBorder)
                }
            }

            Section(header: Text("Release")) {
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
            }

            Section(header: Text("Label")) {
                HStack {
                    Text("Name")
                    TextField("", text: $label)
                        .textFieldStyle(.roundedBorder)
                }

                Toggle("Indie label", isOn: $indieLabel)
            }

            Section(header: Text("Additional information")) {
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
            }

            Section {
                Button(action: {}, label: {
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
}

struct AdvancedSearchAlbumsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AdvancedSearchAlbumsView()
        }
        .environment(\.colorScheme, .dark)
        .environmentObject(Preferences())
    }
}
