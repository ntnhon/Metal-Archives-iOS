//
//  SearchViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 17/11/2022.
//

import CoreData

@MainActor
final class SearchViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published private(set) var entries = [SearchEntry]()

    let datasource: SearchEntryDatasource

    init() {
        datasource = .init(container: .Builder.build(name: kContainerName))
    }

    func fetchEntries() async {
        defer { isLoading = false }
        do {
            isLoading = entries.isEmpty
            let entries = try await datasource.getAllEntries()
            self.entries = entries
        } catch {
            self.error = error
        }
    }

    func removeAllEntries() {
        Task { [weak self] in
            guard let self else { return }
            do {
                try await datasource.removeAllEntries()
                await fetchEntries()
            } catch {
                self.error = error
            }
        }
    }

    func remove(entry: SearchEntry) {
        Task { [weak self] in
            guard let self else { return }
            do {
                try await datasource.removeEntry(entry)
                await fetchEntries()
            } catch {
                self.error = error
            }
        }
    }
}
