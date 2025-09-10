//
//  HeroesStorageService.swift
//  HeroesCore
//
//  Created by Omar Tarek Mansour Omar on 17/8/25.
//

import Foundation
import CoreData

// MARK: - Storage Service Protocol
public protocol HeroesStorageServiceProtocol: Sendable {
    func fetchAllHeroes() async throws -> [Hero]
    func storeHeroes(_ heroes: [Hero], offset: Int) async throws
    func flushHeroes() async throws
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
    public func fetchAllHeroes() async throws -> [Hero] {
        // as best practice for core data we fetch data using ViewContext.
        // in our use case if we use backgroundContext, it is gonna be fine as well, because the data is mapped to domain model
        // and handled back to the viewModel which is a MainActor.
        // we can pick that approach if we noticed that our list/cache is growing crazy like (+4-5K heroes), But always:
        // - Fetch on background.
        // - Map to value types (Hero) inside that context.
        // - Return only value types to @MainActor ViewModel.
        try await stack.viewContext.perform { [stack] in
            let request: NSFetchRequest<HeroEntity> = HeroEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "sortIndex", ascending: true)]
            request.fetchBatchSize = 100
            request.returnsObjectsAsFaults = true
            request.includesPendingChanges = false

            let entities = try stack.viewContext.fetch(request)
            return entities.map { $0.toDomainModel() }
        }
    }

    // MARK: - Store on background context (async, non-blocking)
    public func storeHeroes(_ heroes: [Hero], offset: Int) async throws {
        let context = stack.newBackgroundContext()
        try await context.perform {
            for (index, hero) in heroes.enumerated() {
                // [upset enabled] Blind insert → Core Data auto-updates if hero.id already exists
                let entity = HeroEntity(context: context)
                entity.id = Int64(hero.id)
                entity.update(with: hero, context: context)
                entity.sortIndex = Int64(offset + index)
            }
            // viewContext should have automaticallyMergesChangesFromParent = true
            try context.save()
        }
    }

    // MARK: - Flush (async, non-blocking)
    public func flushHeroes() async throws {
        let context = stack.newBackgroundContext()
        try await context.perform { [stack] in
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = HeroEntity.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            deleteRequest.resultType = .resultTypeObjectIDs

            let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
            if let objectIDs = result?.result as? [NSManagedObjectID], !objectIDs.isEmpty {
                // Batch ops bypass change tracking; merge IDs into the UI context.
                let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: objectIDs]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes,
                                                    into: [stack.viewContext])
            }
        }
    }
}
