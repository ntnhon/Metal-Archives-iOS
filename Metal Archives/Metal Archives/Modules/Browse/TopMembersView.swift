//
//  TopMembersView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 17/10/2022.
//

import SwiftUI

struct TopMembersView: View {
    @StateObject private var viewModel: TopMembersViewModel

    init(apiService: APIServiceProtocol) {
        _viewModel = .init(wrappedValue: .init(apiService: apiService))
    }

    var body: some View {
        ZStack {
            switch viewModel.topUsersFetchable {
            case .fetching:
                HornCircularLoader()
            case .fetched(let topUsers):
                List {
                    ForEach(topUsers.bySubmittedBands, id: \.user.urlString) { user in
                        Text(user.user.name)
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
            await viewModel.fetchTopUsers()
        }
    }
}
