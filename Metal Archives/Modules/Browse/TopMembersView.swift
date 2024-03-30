//
//  TopMembersView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 17/10/2022.
//

import SwiftUI

struct TopMembersView: View {
    @EnvironmentObject private var preferences: Preferences
    @StateObject private var viewModel: TopMembersViewModel

    init(apiService: APIServiceProtocol) {
        _viewModel = .init(wrappedValue: .init(apiService: apiService))
    }

    var body: some View {
        ZStack {
            switch viewModel.topUsersFetchable {
            case .fetching:
                HornCircularLoader()
            case .fetched:
                List {
                    ForEach(0..<viewModel.topUsers.count, id: \.self) { index in
                        let user = viewModel.topUsers[index]
                        NavigationLink(destination: {
                            UserView(apiService: viewModel.apiService, urlString: user.user.urlString)
                        }, label: {
                            HStack {
                                Text("\(index + 1). ")
                                Text(user.user.name)
                                    .foregroundColor(preferences.theme.primaryColor)
                                Spacer()
                                Text("\(user.count)")
                            }
                        })
                    }
                }
                .listStyle(.plain)
            case .error(let error):
                HStack {
                    Text(error.userFacingMessage)
                    RetryButton {
                        await viewModel.fetchTopUsers()
                    }
                }
            }
        }
        .navigationTitle("Top 100 members")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .task {
            await viewModel.fetchTopUsers()
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Menu(content: {
                ForEach(TopMembersCategory.allCases, id: \.self) { category in
                    Button(action: {
                        viewModel.category = category
                    }, label: {
                        if viewModel.category == category {
                            Label(category.description, systemImage: "checkmark")
                        } else {
                            Text(category.description)
                        }
                    })
                }
            }, label: {
                Text(viewModel.category.description)
            })
            .transaction { transaction in
                transaction.animation = nil
            }
            .opacity(viewModel.isFetched ? 1 : 0)
            .disabled(!viewModel.isFetched)
        }
    }
}
