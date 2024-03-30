//
//  SearchEntryDatasource.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 17/11/2022.
//

import CoreData

private let kPageSize = 50

final class SearchEntryDatasource: LocalDatasource, LocalDatasourceProtocol {
    /// Only fetch latest 50 entries
    func getAllEntries() async throws -> [SearchEntry] {
        let taskContext = newTaskContext(type: .fetch)
        let fetchRequest = SearchEntryEntity.fetchRequest()
        fetchRequest.sortDescriptors = [.init(key: "timestamp", ascending: false)]
        fetchRequest.fetchLimit = kPageSize
        let itemEntities = try await execute(fetchRequest: fetchRequest, context: taskContext)
        return itemEntities.map { $0.toSearchEntry() }
    }

    func upsert(_ entry: SearchEntry) async throws {
        let taskContext = newTaskContext(type: .insert)
        let fetchRequest = fetchRequest(for: entry)
        if let entity = try await execute(fetchRequest: fetchRequest, context: taskContext).first {
            entity.hydrate(from: entry)
        } else {
            let newEntity = SearchEntryEntity(context: taskContext)
            newEntity.hydrate(from: entry)
        }
        try taskContext.save()
    }

    func upsertQueryEntry(_ query: String, type: SimpleSearchType) async throws {
        let entry = SearchEntry(type: type.toEntryType(),
                                primaryDetail: query,
                                secondaryDetail: nil)
        try await upsert(entry)
    }

    func upsertBandEntry(_ band: BandLite) async throws {
        let entry = SearchEntry(type: .band,
                                primaryDetail: band.name,
                                secondaryDetail: band.thumbnailInfo.urlString)
        try await upsert(entry)
    }

    func upsertReleaseEntry(_ release: ReleaseLite) async throws {
        let entry = SearchEntry(type: .release,
                                primaryDetail: release.title,
                                secondaryDetail: release.thumbnailInfo.urlString)
        try await upsert(entry)
    }

    func upsertArtistEntry(_ artist: ArtistLite) async throws {
        let entry = SearchEntry(type: .artist,
                                primaryDetail: artist.name,
                                secondaryDetail: artist.thumbnailInfo.urlString)
        try await upsert(entry)
    }

    func upsertLabelEntry(_ label: LabelLite) async throws {
        let entry = SearchEntry(type: .label,
                                primaryDetail: label.name,
                                secondaryDetail: label.thumbnailInfo?.urlString)
        try await upsert(entry)
    }

    func upsertUserEntry(_ user: UserLite) async throws {
        let entry = SearchEntry(type: .user,
                                primaryDetail: user.name,
                                secondaryDetail: user.urlString)
        try await upsert(entry)
    }

    func removeEntry(_ entry: SearchEntry) async throws {
        let taskContext = newTaskContext(type: .delete)
        let fetchRequest = fetchRequest(for: entry)
        if let entity = try await execute(fetchRequest: fetchRequest, context: taskContext).first {
            taskContext.delete(entity)
        }
        try taskContext.save()
    }

    func removeAllEntries() async throws {
        let taskContext = newTaskContext(type: .delete)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SearchEntryEntity")
        try await execute(batchDeleteRequest: .init(fetchRequest: fetchRequest),
                          context: taskContext)
    }

    private func fetchRequest(for entry: SearchEntry) -> NSFetchRequest<SearchEntryEntity> {
        let fetchRequest = SearchEntryEntity.fetchRequest()
        let secondaryDetailPredicate: NSPredicate
        if let secondaryDetail = entry.secondaryDetail {
            secondaryDetailPredicate = .init(format: "secondaryDetail == %@", secondaryDetail)
        } else {
            secondaryDetailPredicate = .init(format: "secondaryDetail == nil")
        }
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            .init(format: "type == %d", entry.type.rawValue),
            .init(format: "primaryDetail == %@", entry.primaryDetail),
            secondaryDetailPredicate
        ])
        return fetchRequest
    }
}

extension SimpleSearchType {
    func toEntryType() -> SearchEntryType {
        switch self {
        case .bandName: return .bandNameQuery
        case .musicGenre: return .musicGenreQuery
        case .lyricalThemes: return .lyricalThemesQuery
        case .albumTitle: return .albumTitleQuery
        case .songTitle: return .songTitleQuery
        case .label: return .labelQuery
        case .artist: return .artistQuery
        case .user: return .userQuery
        }
    }
}
