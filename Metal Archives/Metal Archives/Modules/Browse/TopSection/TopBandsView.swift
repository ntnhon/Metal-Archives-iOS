//
//  TopBandsView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 16/10/2022.
//

import SwiftUI

struct TopBandsView: View {
    @StateObject private var viewModel: TopBandsViewModel

    init(apiService: APIServiceProtocol, category: TopBandsCategory) {
        _viewModel = .init(wrappedValue: .init(apiService: apiService,
                                               category: category))
    }

    var body: some View {
        Text("Top bands")
            .navigationTitle(viewModel.category.title)
            .navigationBarTitleDisplayMode(.inline)
    }
}
