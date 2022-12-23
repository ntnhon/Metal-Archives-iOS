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
private typealias AddedLabelsViewModel = HomeSectionViewModel<AddedLabel>
private typealias AddedArtistsViewModel = HomeSectionViewModel<AddedArtist>

struct LatestAdditionsSection: View {
    @State private var selectedAdditionType = AdditionType.bands
    @StateObject private var addedBandsViewModel: AddedBandsViewModel
    @StateObject private var addedLabelsViewModel: AddedLabelsViewModel
    @StateObject private var addedArtistsViewModel: AddedArtistsViewModel
    @Binding var detail: Detail?

    init(apiService: APIServiceProtocol,
         detail: Binding<Detail?>) {
        let addedBandsViewModel = AddedBandsViewModel(apiService: apiService,
                                                      manager: AddedBandPageManager(apiService: apiService))
        self._addedBandsViewModel = .init(wrappedValue: addedBandsViewModel)
        let addedLabelsViewModel = AddedLabelsViewModel(apiService: apiService,
                                                        manager: AddedLabelPageManager(apiService: apiService))
        self._addedLabelsViewModel = .init(wrappedValue: addedLabelsViewModel)
        let addedArtistsViewModel = AddedArtistsViewModel(apiService: apiService,
                                                          manager: AddedArtistPageManager(apiService: apiService))
        self._addedArtistsViewModel = .init(wrappedValue: addedArtistsViewModel)
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
                AddedLabelsView(viewModel: addedLabelsViewModel, detail: $detail)
            case .artists:
                AddedArtistsView(viewModel: addedArtistsViewModel, detail: $detail)
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
                        Text("No last added bands")
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

// MARK: - Labels
private struct AddedLabelsView: View {
    @ObservedObject var viewModel: AddedLabelsViewModel
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
                        Text("No last added labels")
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
            ForEach(viewModel.chunkedResults, id: \.hashValue) { addedLabels in
                VStack(spacing: HomeSettings.entrySpacing) {
                    ForEach(addedLabels) { label in
                        AddedLabelView(addedLabel: label)
                            .onTapGesture {
                                if let urlString = label.label.thumbnailInfo?.urlString {
                                    detail = .label(urlString)
                                }
                            }
                    }
                }
                .snapAlignmentHelper(id: addedLabels.hashValue)
            }
        }
        .frame(height: HomeSettings.pageHeight)
    }
}

private struct AddedLabelView: View {
    @EnvironmentObject private var preferences: Preferences
    let addedLabel: AddedLabel

    var body: some View {
        HStack {
            if let thumbnailInfo = addedLabel.label.thumbnailInfo {
                ThumbnailView(thumbnailInfo: thumbnailInfo,
                              photoDescription: addedLabel.label.name)
                .font(.largeTitle)
                .foregroundColor(preferences.theme.secondaryColor)
                .frame(width: 64, height: 64)
            }

            VStack(alignment: .leading) {
                Text(addedLabel.label.name)
                    .fontWeight(.bold)
                    .foregroundColor(preferences.theme.primaryColor)

                Text(addedLabel.country.nameAndFlag)
                    .fontWeight(.medium)
                    .foregroundColor(preferences.theme.secondaryColor)

                Text(addedLabel.status.rawValue)
                    .foregroundColor(addedLabel.status.color)

                Text(addedLabel.dateAndTime)

                Divider()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: HomeSettings.entryWidth)
        .contentShape(Rectangle())
    }
}

// MARK: - Artist
private struct AddedArtistsView: View {
    @ObservedObject var viewModel: AddedArtistsViewModel
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
                        Text("No last added artist")
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
            ForEach(viewModel.chunkedResults, id: \.hashValue) { addedArtists in
                VStack(spacing: HomeSettings.entrySpacing) {
                    ForEach(addedArtists) { artist in
                        AddedArtistView(addedArtist: artist)
                            .onTapGesture { detail = .artist(artist.artist.thumbnailInfo.urlString) }
                    }
                }
                .snapAlignmentHelper(id: addedArtists.hashValue)
            }
        }
        .frame(height: HomeSettings.pageHeight)
    }
}

private struct AddedArtistView: View {
    @EnvironmentObject private var preferences: Preferences
    let addedArtist: AddedArtist

    var body: some View {
        HStack {
            ThumbnailView(thumbnailInfo: addedArtist.artist.thumbnailInfo,
                          photoDescription: addedArtist.artist.name)
            .font(.largeTitle)
            .foregroundColor(preferences.theme.secondaryColor)
            .frame(width: 64, height: 64)

            VStack(alignment: .leading) {
                if let realName = addedArtist.realName {
                    Text(addedArtist.artist.name)
                        .fontWeight(.bold)
                        .foregroundColor(preferences.theme.primaryColor) +
                    Text("(\(realName))")
                } else {
                    Text(addedArtist.artist.name)
                        .fontWeight(.bold)
                        .foregroundColor(preferences.theme.primaryColor)
                }

                let texts = addedArtist.bands
                    .generateTexts(fontWeight: .medium,
                                   foregroundColor: preferences.theme.secondaryColor)
                texts.reduce(into: Text("")) { partialResult, text in
                    // swiftlint:disable:next shorthand_operator
                    partialResult = partialResult + text
                }
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(2)
                .minimumScaleFactor(0.5)

                Text(addedArtist.country.nameAndFlag)
                    .fontWeight(.medium)

                Text(addedArtist.dateAndTime)

                Divider()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: HomeSettings.entryWidth)
        .contentShape(Rectangle())
    }
}
