//
//  NewsArchivesViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 23/10/2022.
//

import Factory
import SwiftUI

@MainActor
final class NewsArchivesViewModel: ObservableObject {
    @Published private(set) var news = [NewsPost]()
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    private let apiService = resolve(\DependenciesContainer.apiService)
    private var currentPage = 0
    private var canLoadMore = true

    init() {}

    func fetchMoreIfNeeded(currentPost: NewsPost?) async {
        guard let currentPost else {
            await fetchMore()
            return
        }

        let thresholdIndex = news.index(news.endIndex, offsetBy: -1)
        if news.firstIndex(where: { $0 == currentPost }) == thresholdIndex {
            await fetchMore()
        }
    }

    private func fetchMore() async {
        guard canLoadMore else { return }
        defer { isLoading = false }
        do {
            isLoading = true
            let news = try await newsPost(page: currentPage)
            self.news.append(contentsOf: news)
            currentPage += 1
            canLoadMore = !news.isEmpty
        } catch {
            self.error = error
        }
    }

    func refresh() async {
        defer { isLoading = false }
        do {
            isLoading = true
            news = try await newsPost(page: 0)
            currentPage = 1
            canLoadMore = true
        } catch {
            self.error = error
        }
    }

    private func newsPost(page: Int) async throws -> [NewsPost] {
        let urlString = "https://www.metal-archives.com/news/index/p/\(page + 1)"
        let page = try await apiService.request(forType: NewsPage.self, urlString: urlString)
        return page.newsPosts
    }
}
