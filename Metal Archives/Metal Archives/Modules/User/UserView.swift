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
    @StateObject private var tabsDatasource: UserTabsDatasource
    let user: User

    init(user: User) {
        self.user = user
        self._tabsDatasource = .init(wrappedValue: .init(user: user))
    }

    var body: some View {
        ScrollView {
            VStack {
                UserInfoView(user: user)

                HorizontalTabs(datasource: tabsDatasource)
                    .padding(.vertical)
                    .background(Color(.systemBackground))
            }
        }
        .navigationTitle(user.username)
        .navigationBarTitleDisplayMode(.large)
    }
}
