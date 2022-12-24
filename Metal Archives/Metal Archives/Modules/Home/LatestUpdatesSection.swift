//
//  LatestUpdatesSection.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 04/12/2022.
//

import SwiftUI

struct LatestUpdatesSection: View {
    @State private var selectedObject = LatestObject.bands
    @StateObject private var updatedBandsViewModel: LatestBandsViewModel
    @StateObject private var updatedLabelsViewModel: LatestLabelsViewModel
    @StateObject private var updateArtistsViewModel: LatestArtistsViewModel
    @Binding var detail: Detail?

    init(apiService: APIServiceProtocol,
         detail: Binding<Detail?>) {
        let latestBandPageManager = LatestBandPageManager(apiService: apiService, type: .updated)
        let addedBandsViewModel = LatestBandsViewModel(apiService: apiService,
                                                       manager: latestBandPageManager)
        self._updatedBandsViewModel = .init(wrappedValue: addedBandsViewModel)

        let latestLabelPageManager = LatestLabelPageManager(apiService: apiService, type: .updated)
        let addedLabelsViewModel = LatestLabelsViewModel(apiService: apiService,
                                                         manager: latestLabelPageManager)
        self._updatedLabelsViewModel = .init(wrappedValue: addedLabelsViewModel)

        let latestArtistPageManager = LatestArtistPageManager(apiService: apiService, type: .updated)
        let addedArtistsViewModel = LatestArtistsViewModel(apiService: apiService,
                                                           manager: latestArtistPageManager)
        self._updateArtistsViewModel = .init(wrappedValue: addedArtistsViewModel)

        self._detail = detail
    }

    var body: some View {
        VStack {
            HStack {
                Text("Latest updates")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Spacer()
                NavigationLink(destination: { Text("All") },
                               label: { Text("See All") })
            }
            .padding(.horizontal)

            Picker("", selection: $selectedObject) {
                ForEach(LatestObject.allCases, id: \.rawValue) { type in
                    Text(type.rawValue)
                        .tag(type)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            switch selectedObject {
            case .bands:
                LatestBandsView(viewModel: updatedBandsViewModel, detail: $detail)
                    .frame(minHeight: HomeSettings.pageHeight)
            case .labels:
                LatestLabelsView(viewModel: updatedLabelsViewModel, detail: $detail)
                    .frame(minHeight: HomeSettings.pageHeight)
            case .artists:
                LatestArtistsView(viewModel: updateArtistsViewModel, detail: $detail)
                    .frame(minHeight: HomeSettings.pageHeight)
            }
        }
    }
}
