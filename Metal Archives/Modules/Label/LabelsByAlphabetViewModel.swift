//
//  LabelsByAlphabetViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 22/10/2022.
//

import Combine
import Factory
import SwiftUI

@MainActor
final class LabelsByAlphabetViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published private(set) var labels: [LabelByAlphabet] = []

    @Published var sortOption: LabelByAlphabetPageManager.SortOption = .name(.ascending) {
        didSet { refresh() }
    }

    private let apiService = resolve(\DependenciesContainer.apiService)
    let letter: Letter
    let manager: LabelByAlphabetPageManager
    private var cancellables = Set<AnyCancellable>()

    init(letter: Letter) {
        self.letter = letter
        let defaultSortOption: LabelByAlphabetPageManager.SortOption = .name(.ascending)
        manager = .init(letter: letter, sortOptions: defaultSortOption)

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
