//
//  LocalDatasource.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 17/11/2022.
//

@preconcurrency import CoreData

let kContainerName = "MetalArchives"

enum TaskContextType: String {
    case insert = "insertContext"
    case delete = "deleteContext"
    case fetch = "fetchContext"
}

extension NSPersistentContainer {
    enum Builder {
        static func build(name: String) -> NSPersistentContainer {
            let container = NSPersistentContainer(name: name)
            container.loadPersistentStores { _, error in
                if let error {
                    fatalError("Unresolved error \(error.localizedDescription)")
                }
            }
            return container
        }
    }
}

enum LocalDatasourceError: Error, CustomDebugStringConvertible {
    case batchInsertError(NSBatchInsertRequest)
    case batchDeleteError(NSBatchDeleteRequest)
    case databaseOperationsOnMainThread

    var debugDescription: String {
        switch self {
        case let .batchInsertError(request):
            return "Failed to batch insert entity \(request.entityName)"
        case let .batchDeleteError(request):
            let entityName = request.fetchRequest.entityName ?? ""
            return "Failed to batch delete entity \(entityName)"
        case .databaseOperationsOnMainThread:
            return "Can not do database operations on main thread"
        }
    }
}

/// A base local datasource protocol that has CoreData common operations
protocol LocalDatasourceProtocol: Sendable {
    var container: NSPersistentContainer { get }
}

extension LocalDatasourceProtocol {
    /// Creates and configures a private queue context.
    func newTaskContext(type: TaskContextType,
                        transactionAuthor: String = #function) -> NSManagedObjectContext
    {
        let taskContext = container.newBackgroundContext()
        taskContext.name = type.rawValue
        taskContext.transactionAuthor = transactionAuthor
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        // Set unused undoManager to nil for macOS (it is nil by default on iOS)
        // to reduce resource requirements.
        taskContext.undoManager = nil
        return taskContext
    }

    func newBatchInsertRequest<T>(entity: NSEntityDescription,
                                  sourceItems: [T],
                                  hydrateBlock: @escaping (NSManagedObject, T) -> Void)
        -> NSBatchInsertRequest
    {
        var index = 0
        return NSBatchInsertRequest(entity: entity) { object in
            guard index < sourceItems.count else { return true }
            let item = sourceItems[index]
            hydrateBlock(object, item)
            index += 1
            return false
        }
    }
}

// MARK: - Covenience core data methods

extension LocalDatasourceProtocol {
    func execute(batchInsertRequest request: NSBatchInsertRequest,
                 context: NSManagedObjectContext) async throws
    {
        try await context.perform {
            #if DEBUG
                if Thread.isMainThread {
                    throw LocalDatasourceError.databaseOperationsOnMainThread
                }
            #endif
            let fetchResult = try context.execute(request)
            if let result = fetchResult as? NSBatchInsertResult,
               let success = result.result as? Bool, success
            {
                return
            }
            throw LocalDatasourceError.batchInsertError(request)
        }
    }

    func execute(batchDeleteRequest request: NSBatchDeleteRequest,
                 context: NSManagedObjectContext) async throws
    {
        try await context.perform {
            #if DEBUG
                if Thread.isMainThread {
                    throw LocalDatasourceError.databaseOperationsOnMainThread
                }
            #endif
            request.resultType = .resultTypeStatusOnly
            let deleteResult = try context.execute(request)
            if let result = deleteResult as? NSBatchDeleteResult,
               let success = result.result as? Bool, success
            {
                return
            }
            throw LocalDatasourceError.batchDeleteError(request)
        }
    }

    func execute<T>(fetchRequest request: NSFetchRequest<T>,
                    context: NSManagedObjectContext) async throws -> [T]
    {
        try await context.perform {
            #if DEBUG
                if Thread.isMainThread {
                    throw LocalDatasourceError.databaseOperationsOnMainThread
                }
            #endif
            return try context.fetch(request)
        }
    }

    func count<T>(fetchRequest request: NSFetchRequest<T>,
                  context: NSManagedObjectContext) async throws -> Int
    {
        try await context.perform {
            #if DEBUG
                if Thread.isMainThread {
                    throw LocalDatasourceError.databaseOperationsOnMainThread
                }
            #endif
            return try context.count(for: request)
        }
    }
}

extension NSManagedObject {
    class func entity(context: NSManagedObjectContext) -> NSEntityDescription {
        // swiftlint:disable:next force_unwrapping
        .entity(forEntityName: "\(Self.self)", in: context)!
    }
}
