//
//  LabelCurrentRosterViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 06/11/2022.
//

import Combine
import SwiftUI

@MainActor
final class LabelCurrentRosterViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published private(set) var bands: [LabelCurrentBand] = []

    @Published var sortOption: LabelCurrentBandPageManager.SortOption {
        didSet { refresh() }
    }

    let apiService: APIServiceProtocol
    let manager: LabelCurrentBandPageManager
    private var cancellables = Set<AnyCancellable>()

    init(apiService: APIServiceProtocol, urlString: String) {
        self.apiService = apiService
        let labelId = urlString.components(separatedBy: "/").last ?? ""
        let defaultSortOption: LabelCurrentBandPageManager.SortOption = .band(.ascending)
        self.sortOption = defaultSortOption
        self.manager = .init(apiService: apiService, sortOptions: defaultSortOption, labelId: labelId)

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
