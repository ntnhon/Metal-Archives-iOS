//
//  BandsByGenreViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 22/10/2022.
//

import Combine
import SwiftUI

final class BandsByGenreViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published private(set) var bands: [BandByAlphabet] = []

    @Published var sortOption: BandsByGenrePageManager.SortOption = .band(.ascending) {
        didSet { refresh() }
    }

    let apiService: APIServiceProtocol
    let genre: Genre
    let manager: BandsByGenrePageManager
    private var cancellables = Set<AnyCancellable>()

    init(apiService: APIServiceProtocol, genre: Genre) {
        self.apiService = apiService
        self.genre = genre
        let defaultSortOption: BandsByGenrePageManager.SortOption = .band(.ascending)
        self.manager = .init(apiService: apiService, genre: genre, sortOptions: defaultSortOption)

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

    @MainActor
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
        Task { @MainActor in
            do {
                error = nil
                try await manager.updateOptionsAndRefresh(sortOption.options)
            } catch {
                self.error = error
            }
        }
    }
}
