//
//  LatestArtistsView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 24/12/2022.
//

import SnapToScroll
import SwiftUI

struct LatestArtistsView: View {
    @ObservedObject var viewModel: LatestArtistsViewModel
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
                        Text("No artists")
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
            ForEach(viewModel.chunkedResults, id: \.hashValue) { latestArtists in
                VStack(spacing: HomeSettings.entrySpacing) {
                    ForEach(latestArtists) { artist in
                        LatestArtistView(latestArtist: artist)
                            .onTapGesture { detail = .artist(artist.artist.thumbnailInfo.urlString) }
                    }
                }
                .snapAlignmentHelper(id: latestArtists.hashValue)
            }
        }
        .frame(height: HomeSettings.pageHeight)
    }
}

private struct LatestArtistView: View {
    @EnvironmentObject private var preferences: Preferences
    let latestArtist: LatestArtist

    var body: some View {
        HStack {
            ThumbnailView(thumbnailInfo: latestArtist.artist.thumbnailInfo,
                          photoDescription: latestArtist.artist.name)
            .font(.largeTitle)
            .foregroundColor(preferences.theme.secondaryColor)
            .frame(width: 64, height: 64)

            VStack(alignment: .leading) {
                if let realName = latestArtist.realName {
                    Text(latestArtist.artist.name)
                        .fontWeight(.bold)
                        .foregroundColor(preferences.theme.primaryColor) +
                    Text("(\(realName))")
                } else {
                    Text(latestArtist.artist.name)
                        .fontWeight(.bold)
                        .foregroundColor(preferences.theme.primaryColor)
                }

                let texts = latestArtist.bands
                    .generateTexts(fontWeight: .medium,
                                   foregroundColor: preferences.theme.secondaryColor)
                texts.reduce(into: Text("")) { partialResult, text in
                    // swiftlint:disable:next shorthand_operator
                    partialResult = partialResult + text
                }
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(2)
                .minimumScaleFactor(0.5)

                Text(latestArtist.country.nameAndFlag)
                    .fontWeight(.medium)

                Text(latestArtist.dateAndTime)

                Divider()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: HomeSettings.entryWidth)
        .contentShape(Rectangle())
    }
}
