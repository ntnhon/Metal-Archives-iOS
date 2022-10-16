//
//  TopAlbumsView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 16/10/2022.
//

import SwiftUI

struct TopAlbumsView: View {
    @StateObject private var viewModel: TopAlbumsViewModel

    init(apiService: APIServiceProtocol, category: TopAlbumsCategory) {
        _viewModel = .init(wrappedValue: .init(apiService: apiService,
                                               category: category))
    }

    var body: some View {
        Text("Top albums")
            .navigationTitle(viewModel.category.title)
            .navigationBarTitleDisplayMode(.inline)
    }
}
