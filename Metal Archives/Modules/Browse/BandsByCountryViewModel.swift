//
//  BandsByCountryViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 22/10/2022.
//

import Combine
import Factory
import SwiftUI

@MainActor
final class BandsByCountryViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published private(set) var bands: [BandByCountry] = []

    @Published var sortOption: BandByCountryPageManager.SortOption = .band(.ascending) {
        didSet { refresh() }
    }

    private let apiService = resolve(\DependenciesContainer.apiService)
    let country: Country
    let manager: BandByCountryPageManager
    private var cancellables = Set<AnyCancellable>()

    init(country: Country) {
        self.country = country
        let defaultSortOption: BandByCountryPageManager.SortOption = .band(.ascending)
        manager = .init(country: country, sortOptions: defaultSortOption)

        manager.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.isLoading = isLoading
            }
            .store(in: &cancellables)

        manager.$elements
            .receive(on: DispatchQueue.main)
            .sink { [weak self] bands in
                self?.bands = bands
            }
            .store(in: &cancellables)
    }

    func getMoreBands(force: Bool) async {
        if !force, !bands.isEmpty { return }
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
