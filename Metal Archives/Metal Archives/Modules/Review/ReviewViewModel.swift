//
//  ReviewViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 16/10/2022.
//

import SwiftUI

final class ReviewViewModel: ObservableObject {
    @Published private(set) var reviewFetchable: FetchableObject<Review> = .fetching

    let apiService: APIServiceProtocol
    let urlString: String

    init(apiService: APIServiceProtocol, urlString: String) {
        self.apiService = apiService
        self.urlString = urlString
    }

    @MainActor
    func fetchRelease() async {
        if case .fetched = reviewFetchable { return }
        do {
            reviewFetchable = .fetching
            let review = try await apiService.request(forType: Review.self, urlString: urlString)
            reviewFetchable = .fetched(review)
        } catch {
            reviewFetchable = .error(error)
        }
    }
}
