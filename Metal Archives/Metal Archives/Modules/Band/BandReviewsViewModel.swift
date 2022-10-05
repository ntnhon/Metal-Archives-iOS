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

    private let releases: [ReleaseInBand]
    private let manager: ReviewLitePageManager
    private var cancellables = Set<AnyCancellable>()

    init(bandId: String,
         apiService: APIServiceProtocol,
         releases: [ReleaseInBand]) {
        let manager = ReviewLitePageManager(bandId: bandId, apiService: apiService)
        self.manager = manager
        self.releases = releases

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

    func release(for review: ReviewLite) -> ReleaseInBand {
        releases.first { $0.title == review.title } ?? .init(thumbnailInfo: .death,
                                                             title: "",
                                                             type: .demo,
                                                             year: 0,
                                                             reviewCount: nil,
                                                             rating: nil,
                                                             reviewsUrlString: nil,
                                                             isPlatinium: false)
    }
}
