//
//  UserSubmittedBandsViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 08/11/2022.
//

import Combine
import SwiftUI

@MainActor
final class UserSubmittedBandsViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published private(set) var bands: [UserSubmittedBand] = []

    @Published var sortOption: UserSubmittedBandPageManager.SortOption {
        didSet { refresh() }
    }

    let manager: UserSubmittedBandPageManager
    private var cancellables = Set<AnyCancellable>()

    init(userId: String) {
        let defaultSortOption: UserSubmittedBandPageManager.SortOption = .date(.descending)
        sortOption = defaultSortOption
        manager = .init(sortOptions: defaultSortOption, userId: userId)

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

    func refresh() {
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
