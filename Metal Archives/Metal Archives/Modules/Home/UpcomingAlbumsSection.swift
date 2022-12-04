//
//  UpcomingAlbumsSection.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 04/12/2022.
//

import SwiftUI

typealias UpcomingAlbumsSectionViewModel = AdvancedSearchResultViewModel<UpcomingAlbum>

struct UpcomingAlbumsSection: View {
    @StateObject private var viewModel: UpcomingAlbumsSectionViewModel
    @State private var selectedBandUrl: String?
    @State private var selectedReleaseUrl: String?

    init(apiService: APIServiceProtocol) {
        _viewModel = .init(wrappedValue: .init(apiService: apiService,
                                               manager: UpcomingAlbumPageManager(apiService: apiService)))
    }

    var body: some View {
        ZStack {
            if let error = viewModel.error {
                VStack {
                    Text(error.userFacingMessage)
                    RetryButton(onRetry: viewModel.refresh)
                }
            } else if viewModel.isLoading && viewModel.results.isEmpty {
                ProgressView()
            } else if viewModel.results.isEmpty {
                Text("No upcoming albums")
                    .font(.callout.italic())
            } else {
                resultList
            }
        }
        .task {
            await viewModel.getMoreResults(force: false)
        }
    }

    private var resultList: some View {
        VStack {
            ForEach(viewModel.results, id: \.hashValue) { upcomingAlbum in
                UpcomingAlbumView(upcomingAlbum: upcomingAlbum)
            }
        }
    }
}

private struct UpcomingAlbumView: View {
    let upcomingAlbum: UpcomingAlbum

    var body: some View {
        Text(upcomingAlbum.release.title)
    }
}
