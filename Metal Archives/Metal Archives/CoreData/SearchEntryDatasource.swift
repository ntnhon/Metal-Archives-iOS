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
        let entity = SearchEntryEntity.entity(context: taskContext)
        let batchInsertRequest = newBatchInsertRequest(entity: entity,
                                                       sourceItems: [entry]) { managedObject, item in
            (managedObject as? SearchEntryEntity)?.hydrate(from: item)
        }
        try await execute(batchInsertRequest: batchInsertRequest, context: taskContext)
    }

    func removeAllEntries() async throws {
        let taskContext = newTaskContext(type: .delete)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SearchEntryEntity")
        try await execute(batchDeleteRequest: .init(fetchRequest: fetchRequest),
                          context: taskContext)
    }
}
