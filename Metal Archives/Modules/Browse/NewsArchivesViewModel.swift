//
//  NewsArchivesViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 23/10/2022.
//

import SwiftUI

@MainActor
final class NewsArchivesViewModel: ObservableObject {
    @Published private(set) var news = [NewsPost]()
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    let apiService: APIServiceProtocol
    private var currentPage = 0
    private var canLoadMore = true

    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }

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
            self.isLoading = true
            let news = try await newsPost(page: currentPage)
            self.news.append(contentsOf: news)
            self.currentPage += 1
            self.canLoadMore = !news.isEmpty
        } catch {
            self.error = error
        }
    }

    func refresh() async {
        defer { isLoading = false }
        do {
            self.isLoading = true
            self.news = try await newsPost(page: 0)
            self.currentPage = 1
            self.canLoadMore = true
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
