//
//  BandReviewsViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 03/10/2022.
//

import SwiftUI

final class BandReviewsViewModel: ObservableObject {
    let manager: ReviewLitePageManager

    init(bandId: String, apiService: APIServiceProtocol) {
        self.manager = .init(bandId: bandId, apiService: apiService)
    }

    @MainActor
    func getReviews() async {
        do {
            let result = try await manager.getElements(page: 0, options: [:])
            result.elements
            print(result.elements.count)
        } catch {
            print(error.userFacingMessage)
        }
    }
}
