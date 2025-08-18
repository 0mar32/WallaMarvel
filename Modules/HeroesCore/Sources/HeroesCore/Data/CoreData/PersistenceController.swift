//
//  PersistenceController.swift
//  HeroesCore
//
//  Created by Omar Tarek Mansour Omar on 17/8/25.
//
import Foundation
import CoreData

public final class PersistenceController: Sendable {
    public static let shared = PersistenceController(inMemory: false)

    public let container: NSPersistentContainer

    public init(inMemory: Bool = false) {
        let bundle = Bundle.module // works for Swift Package Manager
        let model = NSManagedObjectModel.mergedModel(from: [bundle])!
        container = NSPersistentContainer(name: "HeroesModel", managedObjectModel: model)

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }

        // View context setup
        let viewContext = container.viewContext
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.mergePolicy = NSMergePolicy(merge: .overwriteMergePolicyType)
    }

    // Create a new background context for safe writes
    public func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergePolicy(merge: .overwriteMergePolicyType)
        return context
    }
}
