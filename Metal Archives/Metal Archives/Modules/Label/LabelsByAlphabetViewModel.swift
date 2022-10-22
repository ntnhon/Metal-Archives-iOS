//
//  LabelsByAlphabetViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 22/10/2022.
//

import Combine
import SwiftUI

final class LabelsByAlphabetViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published private(set) var labels: [LabelByAlphabet] = []

    @Published var sortOption: LabelByAlphabetPageManager.SortOption = .name(.ascending) {
        didSet { refresh() }
    }

    let apiService: APIServiceProtocol
    let letter: Letter
    let manager: LabelByAlphabetPageManager
    private var cancellables = Set<AnyCancellable>()

    init(apiService: APIServiceProtocol, letter: Letter) {
        self.apiService = apiService
        self.letter = letter
        let defaultSortOption: LabelByAlphabetPageManager.SortOption = .name(.ascending)
        self.manager = .init(apiService: apiService, letter: letter, sortOptions: defaultSortOption)

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

    @MainActor
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
