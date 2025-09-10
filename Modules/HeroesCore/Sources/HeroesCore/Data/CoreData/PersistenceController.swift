//
//  PersistenceController.swift
//  HeroesCore
//
//  Created by Omar Tarek Mansour Omar on 17/8/25.
//

import Foundation
import CoreData
import AppConfig

public final class PersistenceController: Sendable {
    public static let shared = PersistenceController(inMemory: false)

    public let container: NSPersistentContainer

    public init(inMemory: Bool = false) {
        // 1) Load the model robustly (works in app, frameworks, and UITests)
        let modelName = "HeroesModel"
        let model: NSManagedObjectModel = {
            // Try explicit momd in common bundles first
            let candidateBundles: [Bundle] = [
                Bundle.module,                // SPM package (if applicable)
                Bundle.main,                  // App bundle
                Bundle(for: DummySentinel.self) // This module’s bundle
            ]

            for bundle in candidateBundles {
                if let url = bundle.url(forResource: modelName, withExtension: "momd"),
                   let managedObject = NSManagedObjectModel(contentsOf: url) {
                    return managedObject
                }
                if let url = bundle.url(forResource: modelName, withExtension: "mom"),
                   let managedObject = NSManagedObjectModel(contentsOf: url) {
                    return managedObject
                }
            }

            // Fallback: merged from all bundles (slower but resilient in UI tests)
            if let merged = NSManagedObjectModel.mergedModel(from: nil) {
                return merged
            }

            preconditionFailure("💥 Core Data model '\(modelName)' not found in any bundle.")
        }()

        container = NSPersistentContainer(name: modelName, managedObjectModel: model)

        // 2) In-memory for UITests (fast, no disk)
        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        }

        // Enable lightweight migration
        let desc = container.persistentStoreDescriptions.first
        desc?.setOption(true as NSNumber, forKey: NSMigratePersistentStoresAutomaticallyOption)
        desc?.setOption(true as NSNumber, forKey: NSInferMappingModelAutomaticallyOption)

        var loadError: Error?
        container.loadPersistentStores { _, error in
            loadError = error
        }
        if let error = loadError {
            preconditionFailure("💥 Failed to load Core Data store: \(error)")
        }

        // setting merge policy
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy(
            merge: .mergeByPropertyObjectTrumpMergePolicyType
        )
    }

    public func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        return context
    }
}

// Private dummy type to get this module’s bundle
private final class DummySentinel {}
