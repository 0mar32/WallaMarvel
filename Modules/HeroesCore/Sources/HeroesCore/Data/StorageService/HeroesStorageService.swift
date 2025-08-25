//
//  HeroesStorageService.swift
//  HeroesCore
//
//  Created by Omar Tarek Mansour Omar on 17/8/25.
//

import Foundation
import CoreData

// MARK: - Storage Service Protocol
public protocol HeroesStorageServiceProtocol {
    func fetchAllHeroes() throws -> [Hero]
    func storeHeroes(_ heroes: [Hero], offset: Int) throws
    func flushHeroes() throws
}

public final class HeroesStorageService: HeroesStorageServiceProtocol {
    private let stack: CoreDataStack

    public init(stack: CoreDataStack) {
        self.stack = stack
    }

    convenience init () {
        self.init(stack: DefaultCoreDataStack())
    }

    // MARK: - Fetch on main thread (viewContext)
    public func fetchAllHeroes() throws -> [Hero] {
        try stack.viewContext.performAndWait {
            let request: NSFetchRequest<HeroEntity> = HeroEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "sortIndex", ascending: true)]
            let entities = try stack.viewContext.fetch(request)
            return entities.map { $0.toDomainModel() }
        }
    }

    // MARK: - Store on background context
    public func storeHeroes(_ heroes: [Hero], offset: Int) throws {
        let context = stack.newBackgroundContext()
        try context.performAndWait {
            for (index, hero) in heroes.enumerated() {
                let entity = try fetchOrCreateEntity(id: hero.id, context: context)
                entity.update(with: hero, context: context)
                entity.sortIndex = Int64(offset + index)
            }
            try context.save()
        }
    }

    // MARK: - Flush
    public func flushHeroes() throws {
        let context = stack.newBackgroundContext()
        try context.performAndWait {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = HeroEntity.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            deleteRequest.resultType = .resultTypeObjectIDs

            let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
            if let objectIDs = result?.result as? [NSManagedObjectID], !objectIDs.isEmpty {
                let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: objectIDs]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes,
                                                    into: [stack.viewContext])
            }
            try context.save()
        }
    }

    // MARK: - Helpers
    /// @testable can access in unit tests if you need to.
    func fetchOrCreateEntity(id: Int, context: NSManagedObjectContext) throws -> HeroEntity {
        let request = HeroEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        request.fetchLimit = 1
        if let existing = try context.fetch(request).first {
            return existing
        } else {
            let entity = HeroEntity(context: context)
            entity.id = Int64(id)
            return entity
        }
    }
}
