//
//  BandReviewsView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 26/07/2021.
//

import SwiftUI

struct BandReviewsView: View {
    @StateObject private var viewModel: BandReviewsViewModel

    init(bandId: String, apiService: APIServiceProtocol) {
        _viewModel = .init(wrappedValue: .init(bandId: bandId,
                                               apiService: apiService))
    }

    var body: some View {
        Text("Band reviews")
            .task {
               await viewModel.getReviews()
            }
    }
}
