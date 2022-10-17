//
//  TopAlbumsView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 17/10/2022.
//

import SwiftUI

struct TopAlbumsView: View {
    @StateObject private var viewModel: TopAlbumsViewModel

    init(apiService: APIServiceProtocol) {
        _viewModel = .init(wrappedValue: .init(apiService: apiService))
    }

    var body: some View {
        ZStack {
            switch viewModel.topReleasesFetchable {
            case .fetching:
                HornCircularLoader()
            case .fetched(let topReleases):
                List {
                    ForEach(topReleases.byReviews, id: \.release.thumbnailInfo.id) { topRelease in
                        Text("\(topRelease.band.name) - \(topRelease.release.title)")
                    }
                }
            case .error(let error):
                HStack {
                    Text(error.userFacingMessage)
                    RetryButton(onRetry: viewModel.retry)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchTopReleases()
        }
    }
}
