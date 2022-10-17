//
//  TopBandsView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 17/10/2022.
//

import SwiftUI

struct TopBandsView: View {
    @StateObject private var viewModel: TopBandsViewModel

    init(apiService: APIServiceProtocol) {
        _viewModel = .init(wrappedValue: .init(apiService: apiService))
    }

    var body: some View {
        ZStack {
            switch viewModel.topBandsFetchable {
            case .fetching:
                HornCircularLoader()
            case .fetched(let topBands):
                List {
                    ForEach(topBands.byReviews, id: \.name) { band in
                        Text(band.name)
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
            await viewModel.fetchTopBands()
        }
    }
}
