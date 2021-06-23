//
//  AdvancedSearchAlbumsView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/06/2021.
//

import SwiftUI

private let kStartDate = DateFormatter.default.date(from: "1960-01-01 00:00:00") ?? Date()

struct AdvancedSearchAlbumsView: View {
    @State private var bandName = ""
    @State private var exactMatchBandName = false
    @State private var releaseTitle = ""
    @State private var exactMatchReleaseTitle = false
    @State private var fromDate = kStartDate
    @State private var toDate = Date()
    @StateObject private var countrySet = CountrySet()
    @State private var cityStateProvince = ""
    @State private var label = ""
    @State private var indieLabel = false
    @State private var catalogNumber = ""
    @State private var identifier = ""
    @State private var recordingInformation = ""
    @State private var versionDescription = ""
    @State private var additionalNote = ""
    @State private var genre = ""
    @StateObject private var releaseTypeSet = ReleaseTypeSet()
    @StateObject private var releaseFormatSet = ReleaseFormatSet()

    var body: some View {
        List {
            Group {
                TextField("Band name", text: $bandName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Toggle("Exact match band name", isOn: $exactMatchBandName)

                TextField("Release title", text: $releaseTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

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

                NavigationLink(destination: AdvancedSearchCountryListView(countrySet: countrySet)) {
                    HStack {
                        Text("Band country")
                        Spacer()
                        Text(countryDetailString())
                            .font(.callout)
                            .foregroundColor(.gray)
                    }
                }
            }

            Group {
                TextField("City / state / province", text: $cityStateProvince)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Label", text: $label)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Toggle("Indie label", isOn: $indieLabel)

                TextField("Catalog number", text: $catalogNumber)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Identifier (barcode, matrix, etc.)", text: $identifier)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Recording information (studio, city, etc.)", text: $recordingInformation)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Version description (country, digipak, etc.)", text: $versionDescription)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Additional note", text: $additionalNote)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Genre", text: $genre)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            Group {
                NavigationLink(destination: ReleaseTypeListView(releaseTypeSet: releaseTypeSet)) {
                    HStack {
                        Text("Release type")
                        Spacer()
                        Text(releaseTypeDetailString())
                            .font(.callout)
                            .foregroundColor(.gray)
                    }
                }

                NavigationLink(destination: ReleaseFormatListView(releaseFormatSet: releaseFormatSet)) {
                    HStack {
                        Text("Release format")
                        Spacer()
                        Text(releaseFormatDetailString())
                            .font(.callout)
                            .foregroundColor(.gray)
                    }
                }

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
        .navigationBarTitle("Advanced search albums", displayMode: .inline)
    }

    private func countryDetailString() -> String {
        if countrySet.countries.isEmpty {
            return "Any country"
        } else {
            return countrySet.countries.map { $0.name }.joined(separator: ", ")
        }
    }

    private func releaseTypeDetailString() -> String {
        if releaseTypeSet.types.isEmpty {
            return "Any type"
        } else {
            return releaseTypeSet.types.map { $0.description }.joined(separator: ", ")
        }
    }

    private func releaseFormatDetailString() -> String {
        if releaseFormatSet.formats.isEmpty {
            return "Any type"
        } else {
            return releaseFormatSet.formats.map { $0.rawValue }.joined(separator: ", ")
        }
    }
}

struct AdvancedSearchAlbumsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AdvancedSearchAlbumsView()
        }
    }
}
