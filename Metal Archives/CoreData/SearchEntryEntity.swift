//
//  SearchEntryEntity.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 17/11/2022.
//

import CoreData

@objc(SearchEntryEntity)
public class SearchEntryEntity: NSManagedObject {}

extension SearchEntryEntity: Identifiable {}

extension SearchEntryEntity {
    @nonobjc
    class func fetchRequest() -> NSFetchRequest<SearchEntryEntity> {
        NSFetchRequest<SearchEntryEntity>(entityName: "SearchEntryEntity")
    }

    @NSManaged var type: Int16
    @NSManaged var primaryDetail: String
    @NSManaged var secondaryDetail: String?
    @NSManaged var timestamp: Double
}

extension SearchEntryEntity {
    func toSearchEntry() -> SearchEntry {
        let type = SearchEntryType(rawValue: type) ?? .bandNameQuery
        return .init(type: type, primaryDetail: primaryDetail, secondaryDetail: secondaryDetail)
    }

    func hydrate(from entry: SearchEntry) {
        type = entry.type.rawValue
        primaryDetail = entry.primaryDetail
        secondaryDetail = entry.secondaryDetail
        timestamp = Date().timeIntervalSince1970
    }
}
