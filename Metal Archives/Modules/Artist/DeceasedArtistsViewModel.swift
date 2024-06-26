//
//  DeceasedArtistsViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 23/10/2022.
//

import Combine
import SwiftUI

@MainActor
final class DeceasedArtistsViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published private(set) var artists: [DeceasedArtist] = []

    @Published var sortOption: DeceasedArtistPageManager.SortOption = .date(.descending) {
        didSet { refresh() }
    }

    let manager: DeceasedArtistPageManager
    private var cancellables = Set<AnyCancellable>()

    init() {
        let defaultSortOption: DeceasedArtistPageManager.SortOption = .date(.descending)
        manager = .init(sortOptions: defaultSortOption)

        manager.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.isLoading = isLoading
            }
            .store(in: &cancellables)

        manager.$elements
            .receive(on: DispatchQueue.main)
            .sink { [weak self] artists in
                self?.artists = artists
            }
            .store(in: &cancellables)
    }

    func getMoreArtists(force: Bool) async {
        if !force, !artists.isEmpty { return }
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
