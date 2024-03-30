//
//  LabelsByCountryViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 23/10/2022.
//

import Combine
import SwiftUI

@MainActor
final class LabelsByCountryViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published private(set) var labels: [LabelByCountry] = []

    @Published var sortOption: LabelByCountryPageManager.SortOption = .name(.ascending) {
        didSet { refresh() }
    }

    let apiService: APIServiceProtocol
    let country: Country
    let manager: LabelByCountryPageManager
    private var cancellables = Set<AnyCancellable>()

    init(apiService: APIServiceProtocol, country: Country) {
        self.apiService = apiService
        self.country = country
        let defaultSortOption: LabelByCountryPageManager.SortOption = .name(.ascending)
        manager = .init(apiService: apiService, country: country, sortOptions: defaultSortOption)

        manager.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.isLoading = isLoading
            }
            .store(in: &cancellables)

        manager.$elements
            .receive(on: DispatchQueue.main)
            .sink { [weak self] labels in
                self?.labels = labels
            }
            .store(in: &cancellables)
    }

    func getMoreLabels(force: Bool) async {
        if !force, !labels.isEmpty { return }
        do {
            error = nil
            try await manager.getMoreElements()
        } catch {
            self.error = error
        }
    }

    private func refresh() {
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
