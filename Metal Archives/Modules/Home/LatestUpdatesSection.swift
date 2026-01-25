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
    @Binding private var path: NavigationPath

    init(path: Binding<NavigationPath>) {
        let latestBandPageManager = LatestBandPageManager(type: .updated)
        let addedBandsViewModel = LatestBandsViewModel(manager: latestBandPageManager)
        _updatedBandsViewModel = .init(wrappedValue: addedBandsViewModel)

        let latestLabelPageManager = LatestLabelPageManager(type: .updated)
        let addedLabelsViewModel = LatestLabelsViewModel(manager: latestLabelPageManager)
        _updatedLabelsViewModel = .init(wrappedValue: addedLabelsViewModel)

        let latestArtistPageManager = LatestArtistPageManager(type: .updated)
        let addedArtistsViewModel = LatestArtistsViewModel(manager: latestArtistPageManager)
        _updateArtistsViewModel = .init(wrappedValue: addedArtistsViewModel)

        _path = path
    }

    var body: some View {
        Section(content: {
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
                LatestBandsView(viewModel: updatedBandsViewModel, path: $path)
                    .frame(minHeight: HomeSettings.pageHeight)
            case .labels:
                LatestLabelsView(viewModel: updatedLabelsViewModel, path: $path)
                    .frame(minHeight: HomeSettings.pageHeight)
            case .artists:
                LatestArtistsView(viewModel: updateArtistsViewModel, path: $path)
                    .frame(minHeight: HomeSettings.pageHeight)
            }
        }, header: {
            HStack {
                Text("Latest updates")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Spacer()
//                NavigationLink(destination: { Text("All") },
//                               label: { Text("See All") })
            }
            .padding(.horizontal)
        })
    }
}
