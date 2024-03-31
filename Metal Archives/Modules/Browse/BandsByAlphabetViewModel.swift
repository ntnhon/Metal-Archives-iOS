//
//  BandsByAlphabetViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 20/10/2022.
//

import Combine
import Factory
import SwiftUI

@MainActor
final class BandsByAlphabetViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published private(set) var bands: [BandByAlphabet] = []

    @Published var sortOption: BandByAlphabetPageManager.SortOption = .band(.ascending) {
        didSet { refresh() }
    }

    private let apiService = resolve(\DependenciesContainer.apiService)
    let letter: Letter
    let manager: BandByAlphabetPageManager
    private var cancellables = Set<AnyCancellable>()

    init(letter: Letter) {
        self.letter = letter
        let defaultSortOption: BandByAlphabetPageManager.SortOption = .band(.ascending)
        manager = .init(letter: letter, sortOptions: defaultSortOption)

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
