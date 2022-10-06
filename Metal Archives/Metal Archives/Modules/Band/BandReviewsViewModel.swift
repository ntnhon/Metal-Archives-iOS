//
//  BandReviewsViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 03/10/2022.
//

import Combine
import SwiftUI

final class BandReviewsViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published private(set) var reviews: [ReviewLite] = []

    @Published var sortOption: ReviewLitePageManager.SortOption = .date(.descending) {
        didSet { refreshReviews() }
    }

    private let discography: Discography
    private let manager: ReviewLitePageManager
    private var cancellables = Set<AnyCancellable>()

    var reviewCount: Int { discography.reviewCount }

    init(band: Band,
         apiService: APIServiceProtocol,
         discography: Discography) {
        let defaultSortOption = ReviewLitePageManager.SortOption.date(.descending)
        let manager = ReviewLitePageManager(bandId: band.id,
                                            apiService: apiService,
                                            sortOptions: defaultSortOption)
        self.manager = manager
        self.discography = discography
        self.sortOption = defaultSortOption

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
    func getMoreReviews() async {
        do {
            error = nil
            try await manager.getMoreElements()
        } catch {
            self.error = error
        }
    }

    private func refreshReviews() {
        Task { @MainActor in
            do {
                error = nil
                try await manager.updateOptionsAndRefresh(sortOption.options)
            } catch {
                self.error = error
            }
        }
    }

    func release(for review: ReviewLite) -> ReleaseInBand {
        discography.releases.first { $0.title == review.title } ?? .init(thumbnailInfo: .death,
                                                                         title: "",
                                                                         type: .demo,
                                                                         year: 0,
                                                                         reviewCount: nil,
                                                                         rating: nil,
                                                                         reviewsUrlString: nil,
                                                                         isPlatinium: false)
    }
}
