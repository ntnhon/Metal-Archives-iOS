//
//  LatestAdditionsSection.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 04/12/2022.
//

import SnapToScroll
import SwiftUI

enum AdditionType: String, CaseIterable {
    case bands = "Bands"
    case labels = "Labels"
    case artists = "Artists"
}

private typealias AddedBandsViewModel = HomeSectionViewModel<AddedBand>

struct LatestAdditionsSection: View {
    @State private var selectedAdditionType = AdditionType.bands
    @StateObject private var addedBandsViewModel: AddedBandsViewModel
    @Binding var detail: Detail?

    init(apiService: APIServiceProtocol,
         detail: Binding<Detail?>) {
        let addedBandsViewModel = AddedBandsViewModel(apiService: apiService,
                                                      manager: AddedBandPageManager(apiService: apiService))
        self._addedBandsViewModel = .init(wrappedValue: addedBandsViewModel)
        self._detail = detail
    }

    var body: some View {
        VStack {
            HStack {
                Text("Latest additions")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Spacer()
                NavigationLink(destination: { Text("All") },
                               label: { Text("See All") })
            }
            .padding(.horizontal)

            Picker("", selection: $selectedAdditionType) {
                ForEach(AdditionType.allCases, id: \.rawValue) { type in
                    Text(type.rawValue)
                        .tag(type)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            switch selectedAdditionType {
            case .bands:
                AddedBandsView(viewModel: addedBandsViewModel, detail: $detail)
            case .labels:
                Text("Labels")
            case .artists:
                Text("Artist")
            }
        }
    }
}

// MARK: - Bands
private struct AddedBandsView: View {
    @ObservedObject var viewModel: AddedBandsViewModel
    @Binding var detail: Detail?

    var body: some View {
        ZStack {
            if let error = viewModel.error {
                VStack {
                    Text(error.userFacingMessage)
                    RetryButton(onRetry: viewModel.refresh)
                }
            } else {
                Group {
                    if viewModel.isLoading && viewModel.results.isEmpty {
                        HomeSectionSkeletonView()
                    } else if viewModel.results.isEmpty {
                        Text("No latest reviews")
                            .font(.callout.italic())
                    } else {
                        resultList
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .task {
            await viewModel.getMoreResults(force: false)
        }
    }

    private var resultList: some View {
        HStackSnap(alignment: .leading(24)) {
            ForEach(viewModel.chunkedResults, id: \.hashValue) { addedBands in
                VStack(spacing: HomeSettings.entrySpacing) {
                    ForEach(addedBands) { band in
                        AddedBandView(addedBand: band)
                            .onTapGesture { detail = .band(band.band.thumbnailInfo.urlString) }
                    }
                }
                .snapAlignmentHelper(id: addedBands.hashValue)
            }
        }
        .frame(height: HomeSettings.pageHeight)
    }
}

private struct AddedBandView: View {
    @EnvironmentObject private var preferences: Preferences
    let addedBand: AddedBand

    var body: some View {
        HStack {
            ThumbnailView(thumbnailInfo: addedBand.band.thumbnailInfo,
                          photoDescription: addedBand.band.name)
            .font(.largeTitle)
            .foregroundColor(preferences.theme.secondaryColor)
            .frame(width: 64, height: 64)

            VStack(alignment: .leading) {
                Text(addedBand.band.name)
                    .fontWeight(.bold)
                    .foregroundColor(preferences.theme.primaryColor)

                Text(addedBand.country.nameAndFlag)
                    .fontWeight(.medium)
                    .foregroundColor(preferences.theme.secondaryColor)

                Text(addedBand.dateAndTime)

                Text(addedBand.genre)
                    .font(.body.italic())

                Divider()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: HomeSettings.entryWidth)
        .contentShape(Rectangle())
    }
}
