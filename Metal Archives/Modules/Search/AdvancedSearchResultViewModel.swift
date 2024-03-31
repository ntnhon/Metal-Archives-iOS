//
//  AdvancedSearchResultViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 04/12/2022.
//

import Combine
import SwiftUI

@MainActor
class AdvancedSearchResultViewModel<T: HashableEquatablePageElement>: ObservableObject {
    deinit { print("\(Self.self) is deallocated") }

    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published private(set) var results: [T] = []

    let manager: PageManager<T>
    private var cancellables = Set<AnyCancellable>()

    init(manager: PageManager<T>) {
        self.manager = manager

        manager.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.isLoading = isLoading
            }
            .store(in: &cancellables)

        manager.$elements
            .receive(on: DispatchQueue.main)
            .sink { [weak self] results in
                self?.results = results
            }
            .store(in: &cancellables)
    }

    func getMoreResults(force: Bool) async {
        if !force, !results.isEmpty { return }
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
                try await manager.updateOptionsAndRefresh([:])
            } catch {
                self.error = error
            }
        }
    }
}
