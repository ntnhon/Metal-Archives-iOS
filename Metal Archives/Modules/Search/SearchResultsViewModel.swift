//
//  SearchResultsViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 15/11/2022.
//

import Combine
import SwiftUI

typealias HashableEquatablePageElement = Equatable & Hashable & PageElement

@MainActor
final class SearchResultsViewModel<T: HashableEquatablePageElement>: ObservableObject {
    deinit { print("\(Self.self) is deallocated") }

    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published private(set) var results: [T] = []

    // TODO: Handle this
    private var databaseError: Error?

    let apiService: APIServiceProtocol
    let manager: PageManager<T>
    let query: String?
    let datasource: SearchEntryDatasource
    private var cancellables = Set<AnyCancellable>()

    init(apiService: APIServiceProtocol,
         manager: PageManager<T>,
         query: String?,
         datasource: SearchEntryDatasource)
    {
        self.apiService = apiService
        self.manager = manager
        self.query = query
        self.datasource = datasource

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
        if !force, !results.isEmpty {
            return
        }
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

    func upsertBandEntry(_ band: BandLite) {
        Task { [weak self] in
            guard let self else { return }
            do {
                try await datasource.upsertBandEntry(band)
            } catch {
                databaseError = error
            }
        }
    }

    func upsertReleaseEntry(_ release: ReleaseLite) {
        Task { [weak self] in
            guard let self else { return }
            do {
                try await datasource.upsertReleaseEntry(release)
            } catch {
                databaseError = error
            }
        }
    }

    func upsertArtistEntry(_ artist: ArtistLite) {
        Task { [weak self] in
            guard let self else { return }
            do {
                try await datasource.upsertArtistEntry(artist)
            } catch {
                databaseError = error
            }
        }
    }

    func upsertLabelEntry(_ label: LabelLite) {
        Task { [weak self] in
            guard let self else { return }
            do {
                try await datasource.upsertLabelEntry(label)
            } catch {
                databaseError = error
            }
        }
    }

    func upsertUserEntry(_ user: UserLite) {
        Task { [weak self] in
            guard let self else { return }
            do {
                try await datasource.upsertUserEntry(user)
            } catch {
                databaseError = error
            }
        }
    }
}
