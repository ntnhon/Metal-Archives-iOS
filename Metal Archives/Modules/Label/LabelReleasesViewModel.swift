//
//  LabelReleasesViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 06/11/2022.
//

import Combine
import SwiftUI

@MainActor
final class LabelReleasesViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published private(set) var releases: [LabelRelease] = []

    @Published var sortOption: LabelReleasePageManager.SortOption {
        didSet { refresh() }
    }

    let apiService: APIServiceProtocol
    let manager: LabelReleasePageManager
    private var cancellables = Set<AnyCancellable>()

    init(apiService: APIServiceProtocol, urlString: String) {
        self.apiService = apiService
        let labelId = urlString.components(separatedBy: "/").last ?? ""
        let defaultSortOption: LabelReleasePageManager.SortOption = .band(.ascending)
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
            .sink { [weak self] releases in
                self?.releases = releases
            }
            .store(in: &cancellables)
    }

    func getMoreReleases(force: Bool) async {
        if !force, !releases.isEmpty { return }
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
