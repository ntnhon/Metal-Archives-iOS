//
//  NewsArchivesView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 23/10/2022.
//

import SwiftUI

struct NewsArchivesView: View {
    @EnvironmentObject private var preferences: Preferences
    @StateObject private var viewModel = NewsArchivesViewModel()

    var body: some View {
        ZStack {
            if viewModel.isLoading, viewModel.news.isEmpty {
                MALoadingIndicator()
            } else if let error = viewModel.error {
                VStack {
                    Text(error.userFacingMessage)
                    RetryButton {
                        await viewModel.refresh()
                    }
                }
            } else {
                newsList
            }
        }
        .task {
            await viewModel.fetchMoreIfNeeded(currentPost: nil)
        }
    }

    private var newsList: some View {
        List {
            ForEach(viewModel.news, id: \.self) { news in
                NavigationLink(destination: {
                    NewsPostView(newsPost: news)
                }, label: {
                    VStack(alignment: .leading) {
                        Text(news.title)
                            .fontWeight(.bold)
                            .foregroundColor(preferences.theme.primaryColor)
                        Text(news.dateString)
                            .font(.callout.italic())
                            .fontWeight(.medium) +
                            Text(" • ") +
                            Text(news.author.name)
                            .fontWeight(.medium)
                            .foregroundColor(preferences.theme.secondaryColor)
                        Text(news.content)
                            .lineLimit(3)
                    }
                })
                .task {
                    await viewModel.fetchMoreIfNeeded(currentPost: news)
                }
            }
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .listStyle(.plain)
        .navigationTitle("News archives")
        .navigationBarTitleDisplayMode(.large)
    }
}
