//
//  LatestLabelsView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 24/12/2022.
//

import SnapToScroll
import SwiftUI

struct LatestLabelsView: View {
    @ObservedObject var viewModel: LatestLabelsViewModel
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
                        Text("No labels")
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
            ForEach(viewModel.chunkedResults, id: \.hashValue) { latestLabels in
                VStack(spacing: HomeSettings.entrySpacing) {
                    ForEach(latestLabels) { label in
                        LatestLabelView(latestLabel: label)
                            .onTapGesture {
                                if let urlString = label.label.thumbnailInfo?.urlString {
                                    detail = .label(urlString)
                                }
                            }
                    }
                }
                .snapAlignmentHelper(id: latestLabels.hashValue)
            }
        }
        .frame(height: HomeSettings.pageHeight)
    }
}

private struct LatestLabelView: View {
    @EnvironmentObject private var preferences: Preferences
    let latestLabel: LatestLabel

    var body: some View {
        HStack {
            if let thumbnailInfo = latestLabel.label.thumbnailInfo {
                ThumbnailView(thumbnailInfo: thumbnailInfo,
                              photoDescription: latestLabel.label.name)
                .font(.largeTitle)
                .foregroundColor(preferences.theme.secondaryColor)
                .frame(width: 64, height: 64)
            }

            VStack(alignment: .leading) {
                Text(latestLabel.label.name)
                    .fontWeight(.bold)
                    .foregroundColor(preferences.theme.primaryColor)

                Text(latestLabel.country.nameAndFlag)
                    .fontWeight(.medium)
                    .foregroundColor(preferences.theme.secondaryColor)

                Text(latestLabel.status.rawValue)
                    .foregroundColor(latestLabel.status.color)

                Text(latestLabel.dateAndTime)

                Divider()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: HomeSettings.entryWidth)
        .contentShape(Rectangle())
    }
}
