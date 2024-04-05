//
//  LatestAdditionsSection.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 04/12/2022.
//

import SwiftUI

struct LatestAdditionsSection: View {
    @State private var selectedObject = LatestObject.bands
    @StateObject private var addedBandsViewModel: LatestBandsViewModel
    @StateObject private var addedLabelsViewModel: LatestLabelsViewModel
    @StateObject private var addedArtistsViewModel: LatestArtistsViewModel
    @Binding var detail: Detail?

    init(detail: Binding<Detail?>) {
        let latestBandPageManager = LatestBandPageManager(type: .added)
        let addedBandsViewModel = LatestBandsViewModel(manager: latestBandPageManager)
        _addedBandsViewModel = .init(wrappedValue: addedBandsViewModel)

        let latestLabelPageManager = LatestLabelPageManager(type: .added)
        let addedLabelsViewModel = LatestLabelsViewModel(manager: latestLabelPageManager)
        _addedLabelsViewModel = .init(wrappedValue: addedLabelsViewModel)

        let latestArtistPageManager = LatestArtistPageManager(type: .added)
        let addedArtistsViewModel = LatestArtistsViewModel(manager: latestArtistPageManager)
        _addedArtistsViewModel = .init(wrappedValue: addedArtistsViewModel)

        _detail = detail
    }

    var body: some View {
        VStack {
            HStack {
                Text("Latest additions")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Spacer()
//                NavigationLink(destination: { Text("All") },
//                               label: { Text("See All") })
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
                LatestBandsView(viewModel: addedBandsViewModel, detail: $detail)
                    .frame(minHeight: HomeSettings.pageHeight)
            case .labels:
                LatestLabelsView(viewModel: addedLabelsViewModel, detail: $detail)
                    .frame(minHeight: HomeSettings.pageHeight)
            case .artists:
                LatestArtistsView(viewModel: addedArtistsViewModel, detail: $detail)
                    .frame(minHeight: HomeSettings.pageHeight)
            }
        }
    }
}
