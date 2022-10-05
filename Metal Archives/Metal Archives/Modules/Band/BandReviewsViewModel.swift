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

    @Published var albumOrder: Order? { didSet { refreshReviews() } }
    @Published var ratingOrder: Order? { didSet { refreshReviews() } }
    @Published var authorOrder: Order? { didSet { refreshReviews() } }
    @Published var dateOrder: Order? { didSet { refreshReviews() } }

    private let discography: Discography
    private let manager: ReviewLitePageManager
    private var cancellables = Set<AnyCancellable>()

    var reviewCount: Int { discography.reviewCount }

    init(band: Band,
         apiService: APIServiceProtocol,
         discography: Discography) {
        let manager = ReviewLitePageManager(bandId: band.id, apiService: apiService)
        self.manager = manager
        self.discography = discography

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
        print(#function)
        switch albumOrder {
        case .ascending:
            print("Album asc")
        case .descending:
            print("Album desc")
        case .none:
            print("Album none")
        }

        switch ratingOrder {
        case .ascending:
            print("Rating asc")
        case .descending:
            print("Rating desc")
        case .none:
            print("Rating none")
        }

        switch authorOrder {
        case .ascending:
            print("Author asc")
        case .descending:
            print("Author desc")
        case .none:
            print("Author none")
        }

        switch dateOrder {
        case .ascending:
            print("Date asc")
        case .descending:
            print("Date desc")
        case .none:
            print("Date none")
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
