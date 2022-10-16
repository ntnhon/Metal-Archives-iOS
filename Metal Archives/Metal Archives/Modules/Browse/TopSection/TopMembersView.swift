//
//  TopMembersView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 16/10/2022.
//

import SwiftUI

struct TopMembersView: View {
    @StateObject private var viewModel: TopMembersViewModel

    init(apiService: APIServiceProtocol, category: TopMembersCategory) {
        _viewModel = .init(wrappedValue: .init(apiService: apiService,
                                               category: category))
    }

    var body: some View {
        Text("Top members")
            .navigationTitle(viewModel.category.title)
            .navigationBarTitleDisplayMode(.inline)
    }
}
