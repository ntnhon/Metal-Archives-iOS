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
        List {
            Section(header: Text("Band")) {
                TextField("Band name", text: $bandName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Toggle("Exact match band name", isOn: $exactMatchBandName)

                NavigationLink(destination: AdvancedSearchCountryListView(countrySet: countrySet)) {
                    HStack {
                        Text("Band country")
                        Spacer()
                        Text(countrySet.detailString)
                            .font(.callout)
                            .foregroundColor(.gray)
                    }
                }

                TextField("City / state / province", text: $cityStateProvince)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            Section(header: Text("Release")) {
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

                NavigationLink(destination: ReleaseTypeListView(releaseTypeSet: releaseTypeSet)) {
                    HStack {
                        Text("Release type")
                        Spacer()
                        Text(releaseTypeSet.detailString)
                            .font(.callout)
                            .foregroundColor(.gray)
                    }
                }

                NavigationLink(destination: ReleaseFormatListView(releaseFormatSet: releaseFormatSet)) {
                    HStack {
                        Text("Release format")
                        Spacer()
                        Text(releaseFormatSet.detailString)
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
        .navigationBarTitle("Advanced search albums", displayMode: .inline)
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
