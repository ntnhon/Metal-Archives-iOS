//
//  UserView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 16/10/2022.
//

import SwiftUI

struct UserView: View {
    @StateObject private var viewModel: UserViewModel

    init(apiService: APIServiceProtocol, urlString: String) {
        _viewModel = .init(wrappedValue: .init(apiService: apiService,
                                               urlString: urlString))
    }

    var body: some View {
        ZStack {
            switch viewModel.userFetchable {
            case .fetching:
                HornCircularLoader()
            case .fetched(let user):
                UserContentView(user: user)
                    .environmentObject(viewModel)
            case .error(let error):
                VStack {
                    Text(error.userFacingMessage)
                    RetryButton {
                        Task {
                            await viewModel.fetchUser()
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.fetchUser()
        }
    }
}

private struct UserContentView: View {
    @EnvironmentObject private var viewModel: UserViewModel
    let user: User

    var body: some View {
        ScrollView {
            VStack {
                UserInfoView(user: user)
                    .padding(.horizontal)
            }
        }
        .navigationTitle(user.username)
        .navigationBarTitleDisplayMode(.large)
    }
}
