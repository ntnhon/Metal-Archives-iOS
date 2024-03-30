//
//  UserReviewsViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 07/11/2022.
//

import Combine
import SwiftUI

final class UserReviewsViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published private(set) var reviews: [UserReview] = []

    @Published var sortOption: UserReviewPageManager.SortOption {
        didSet { refresh() }
    }

    let apiService: APIServiceProtocol
    let manager: UserReviewPageManager
    private var cancellables = Set<AnyCancellable>()

    init(apiService: APIServiceProtocol, userId: String) {
        self.apiService = apiService
        let defaultSortOption: UserReviewPageManager.SortOption = .date(.descending)
        sortOption = defaultSortOption
        manager = .init(apiService: apiService, sortOptions: defaultSortOption, userId: userId)

        manager.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.isLoading = isLoading
            }
            .store(in: &cancellables)

        manager.$elements
            .receive(on: DispatchQueue.main)
            .sink { [weak self] reviews in
                self?.reviews = reviews
            }
            .store(in: &cancellables)
    }

    @MainActor
    func getMoreReviews(force: Bool) async {
        if !force, !reviews.isEmpty { return }
        do {
            error = nil
            try await manager.getMoreElements()
        } catch {
            self.error = error
        }
    }

    func refresh() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                error = nil
                try await manager.updateOptionsAndRefresh(sortOption.options)
            } catch {
                self.error = error
            }
        }
    }
}
