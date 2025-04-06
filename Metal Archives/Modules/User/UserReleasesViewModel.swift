//
//  UserReleasesViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 09/11/2022.
//

import Combine
import SwiftUI

@MainActor
final class UserReleasesViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published private(set) var releases: [UserRelease] = []

    let manager: UserReleasePageManager
    private var cancellables = Set<AnyCancellable>()

    init(userId: String, type: UserReleaseType) {
        manager = .init(userId: userId, type: type)

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

    @MainActor
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
                try await manager.updateOptionsAndRefresh([:])
            } catch {
                self.error = error
            }
        }
    }
}
