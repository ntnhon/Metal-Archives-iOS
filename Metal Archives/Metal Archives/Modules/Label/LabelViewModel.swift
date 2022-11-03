//
//  LabelViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 15/10/2022.
//

import SwiftUI

final class LabelViewModel: ObservableObject {
//    deinit { print("\(Self.self) of \(urlString) is deallocated") }
    @Published private(set) var labelFetchable: FetchableObject<LabelDetail> = .fetching

    private let apiService: APIServiceProtocol
    private let urlString: String

    init(apiService: APIServiceProtocol, urlString: String) {
        self.apiService = apiService
        self.urlString = urlString
    }

    @MainActor
    func fetchLabel() async {
        if case .fetched = labelFetchable { return }
        do {
            labelFetchable = .fetching
            let label = try await apiService.request(forType: LabelDetail.self, urlString: urlString)
            labelFetchable = .fetched(label)
        } catch {
            labelFetchable = .error(error)
        }
    }
}
