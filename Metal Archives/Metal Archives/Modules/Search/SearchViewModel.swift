//
//  SearchViewModel.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 17/11/2022.
//

import CoreData

final class SearchViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published private(set) var entries = [SearchEntry]()

    let datasource: SearchEntryDatasource

    init() {
        self.datasource = .init(container: .Builder.build(name: kContainerName))
    }

    @MainActor
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
        Task {
            try await datasource.removeAllEntries()
            await fetchEntries()
        }
    }
}
