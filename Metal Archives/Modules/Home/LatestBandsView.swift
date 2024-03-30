//
//  LatestBandsView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 24/12/2022.
//

import SnapToScroll
import SwiftUI

struct LatestBandsView: View {
    @ObservedObject var viewModel: LatestBandsViewModel
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
                        Text("No bands")
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
            ForEach(viewModel.chunkedResults, id: \.hashValue) { latestBands in
                VStack(spacing: HomeSettings.entrySpacing) {
                    ForEach(latestBands) { band in
                        LatestBandView(latestBand: band)
                            .onTapGesture { detail = .band(band.band.thumbnailInfo.urlString) }
                    }
                }
                .snapAlignmentHelper(id: latestBands.hashValue)
            }
        }
        .frame(height: HomeSettings.pageHeight)
    }
}

private struct LatestBandView: View {
    @EnvironmentObject private var preferences: Preferences
    let latestBand: LatestBand

    var body: some View {
        HStack {
            ThumbnailView(thumbnailInfo: latestBand.band.thumbnailInfo,
                          photoDescription: latestBand.band.name)
            .font(.largeTitle)
            .foregroundColor(preferences.theme.secondaryColor)
            .frame(width: 64, height: 64)

            VStack(alignment: .leading) {
                Text(latestBand.band.name)
                    .fontWeight(.bold)
                    .foregroundColor(preferences.theme.primaryColor)

                Text(latestBand.country.nameAndFlag)
                    .fontWeight(.medium)
                    .foregroundColor(preferences.theme.secondaryColor)

                Text(latestBand.dateAndTime)

                Text(latestBand.genre)
                    .font(.body.italic())

                Divider()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: HomeSettings.entryWidth)
        .contentShape(Rectangle())
    }
}
