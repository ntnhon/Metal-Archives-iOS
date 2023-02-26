//
//  LabelPastRosterViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 06/11/2022.
//

import Combine
import SwiftUI

final class LabelPastRosterViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published private(set) var bands: [LabelPastBand] = []

    @Published var sortOption: LabelPastBandPageManager.SortOption {
        didSet { refresh() }
    }

    let apiService: APIServiceProtocol
    let manager: LabelPastBandPageManager
    private var cancellables = Set<AnyCancellable>()

    init(apiService: APIServiceProtocol, urlString: String) {
        self.apiService = apiService
        let labelId = urlString.components(separatedBy: "/").last ?? ""
        let defaultSortOption: LabelPastBandPageManager.SortOption = .band(.ascending)
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
