//
//  CoreDataStack.swift
//  HeroesCore
//
//  Created by Omar Tarek Mansour Omar on 25/8/25.
//

import CoreData
import AppConfig

public protocol CoreDataStack {
    var viewContext: NSManagedObjectContext { get }
    func newBackgroundContext() -> NSManagedObjectContext
}

/// Adapter so you can keep using your existing PersistenceController without changing it.
public struct DefaultCoreDataStack: CoreDataStack {
    private let persistence: PersistenceController

    public init(persistence: PersistenceController) {
        self.persistence = persistence
    }

    public init () {
        if AppEnvironment.isRunningUITests {
            self.init(persistence: .init(inMemory: true))
        } else {
            self.init(persistence: .shared)
        }
    }

    public var viewContext: NSManagedObjectContext {
        persistence.container.viewContext
    }

    public func newBackgroundContext() -> NSManagedObjectContext {
        persistence.newBackgroundContext()
    }
}
