//
//  NSManagedObject.swift
//  OpenMovie
//
//  Created by Anthony Soulier on 10/07/2019.
//  Copyright © 2019 Anthony Soulier. All rights reserved.
//

import CoreData

public typealias KeyObjectDictionary = [String: Any]

extension NSPredicate {
    @inlinable
    public convenience init(format: String, arguments: Any...) {
        self.init(format: format, argumentArray: arguments)
    }
}

fileprivate extension Sequence where Element == KeyObjectDictionary.Element {
    func asPredicate(with compoundType: NSCompoundPredicate.LogicalType) -> NSCompoundPredicate {
        return NSCompoundPredicate(type: compoundType, subpredicates: map {
            NSPredicate(format: "%K == %@", arguments: $0.key, $0.value)
        })
    }

    func apply(to object: NSObject, in context: NSManagedObjectContext) {
        forEach { (key, value) in
            if let id = value as? NSManagedObjectID {
                object.setValue(context.object(with: id), forKey: key)
            } else {
                object.setValue(value, forKey: key)
            }
        }
    }
}

public protocol Fetchable: NSFetchRequestResult {
    static var entityName: String { get }
    static func fetchRequest() -> NSFetchRequest<Self>
    static func count(in context: NSManagedObjectContext) throws -> Int
}

public protocol FindOrCreatable: Fetchable {
    static func create(in context: NSManagedObjectContext, applying: KeyObjectDictionary?) throws -> Self

    static func find(in context: NSManagedObjectContext, by dictionary: KeyObjectDictionary) throws -> [Self]
    static func find(in context: NSManagedObjectContext, by dictionary: KeyObjectDictionary, sortedBy sortDescriptors: [NSSortDescriptor]) throws -> [Self]

    static func find(in context: NSManagedObjectContext, with predicate: NSPredicate?, sortedBy sortDescriptors: [NSSortDescriptor]?) throws -> [Self]

    static func findFirst(in context: NSManagedObjectContext, by dictionary: KeyObjectDictionary) throws -> Self?
    static func findFirst(in context: NSManagedObjectContext, by dictionary: KeyObjectDictionary, sortedBy sortDescriptors: [NSSortDescriptor]) throws -> Self?

    static func findFirst(in context: NSManagedObjectContext, with predicate: NSPredicate?, sortedBy sortDescriptors: [NSSortDescriptor]?) throws -> Self?

    static func findOrCreate(in context: NSManagedObjectContext, by dictionary: KeyObjectDictionary?) throws -> Self

    static func random(upTo randomBound: Int, in context: NSManagedObjectContext) throws -> Self?
}

extension Fetchable {
    @inlinable
    public static func fetchRequest() -> NSFetchRequest<Self> {
        return NSFetchRequest(entityName: entityName)
    }

    public static func fetchRequest(with predicate: NSPredicate?,
                                    sortedBy sortDescriptors: [NSSortDescriptor]?,
                                    offsetBy offset: Int? = nil,
                                    limitedBy limit: Int? = nil) -> NSFetchRequest<Self> {
        let fetchRequest = self.fetchRequest()
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        if let limit = limit {
            fetchRequest.fetchLimit = limit
        }
        if let offset = offset {
            fetchRequest.fetchOffset = offset
        }
        return fetchRequest
    }

    @inlinable
    public static func count(in context: NSManagedObjectContext) throws -> Int {
        return try context.count(for: fetchRequest())
    }
}

extension Fetchable where Self: NSManagedObject {
    @inlinable
    public static var entityName: String {
        return self.entity().name ?? ""
    }
}

extension Fetchable {
    internal static func entity(in context: NSManagedObjectContext) throws -> NSEntityDescription {
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
            throw FindOrCreatableError.invalidEntity(entityName: entityName)
        }
        return entity
    }
}

extension FindOrCreatable {
    @inlinable
    public static func create(in context: NSManagedObjectContext) throws -> Self {
        return try create(in: context, applying: nil)
    }

    @inlinable
    public static func all(in context: NSManagedObjectContext) throws -> [Self] {
        return try find(in: context)
    }

    @inlinable
    public static func find(in context: NSManagedObjectContext) throws -> [Self] {
        return try find(in: context, with: nil)
    }

    public static func find(in context: NSManagedObjectContext, by dictionary: KeyObjectDictionary) throws -> [Self] {
        return try find(in: context, with: dictionary.asPredicate(with: .and))
    }

    public static func find(in context: NSManagedObjectContext, by dictionary: KeyObjectDictionary, sortedBy sortDescriptors: [NSSortDescriptor]) throws -> [Self] {
        return try find(in: context, with: dictionary.asPredicate(with: .and), sortedBy: sortDescriptors)
    }

    @inlinable
    public static func find(in context: NSManagedObjectContext, with predicate: NSPredicate?) throws -> [Self] {
        return try find(in: context, with: predicate, sortedBy: nil)
    }

    @inlinable
    public static func find(in context: NSManagedObjectContext, with predicate: NSPredicate?, sortedBy sortDescriptors: [NSSortDescriptor]?) throws -> [Self] {
        return try context.fetch(fetchRequest(with: predicate, sortedBy: sortDescriptors))
    }

    @inlinable
    public static func findFirst(in context: NSManagedObjectContext) throws -> Self? {
        return try findFirst(in: context, with: nil)
    }

    public static func findFirst(in context: NSManagedObjectContext, by dictionary: KeyObjectDictionary) throws -> Self? {
        return try findFirst(in: context, with: dictionary.asPredicate(with: .and))
    }

    public static func findFirst(in context: NSManagedObjectContext, by dictionary: KeyObjectDictionary, sortedBy sortDescriptors: [NSSortDescriptor]) throws -> Self? {
        return try findFirst(in: context, with: dictionary.asPredicate(with: .and), sortedBy: sortDescriptors)
    }

    @inlinable
    public static func findFirst(in context: NSManagedObjectContext, with predicate: NSPredicate?) throws -> Self? {
        return try findFirst(in: context, with: predicate, sortedBy: nil)
    }

    @inlinable
    public static func findFirst(in context: NSManagedObjectContext, with predicate: NSPredicate?, sortedBy sortDescriptors: [NSSortDescriptor]?) throws -> Self? {
        let request = fetchRequest(with: predicate, sortedBy: sortDescriptors)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    @inlinable
    public static func findOrCreate(in context: NSManagedObjectContext) throws -> Self {
        return try findOrCreate(in: context, by: nil)
    }

    @inlinable
    public static func random(in context: NSManagedObjectContext) throws -> Self? {
        return try random(upTo: count(in: context), in: context)
    }

    public static func random(upTo randomBound: Int, in context: NSManagedObjectContext) throws -> Self? {
        let fr = fetchRequest()
        fr.fetchOffset = Int.random(in: 0..<randomBound)
        fr.fetchLimit = 1
        return try context.fetch(fr).first
    }
}

extension FindOrCreatable where Self: NSManagedObject {
    public static func create(in context: NSManagedObjectContext, applying dictionary: KeyObjectDictionary?) throws -> Self {
        let obj = self.init(entity: try entity(in: context), insertInto: context)
        dictionary?.apply(to: obj, in: context)
        return obj
    }

    public static func findOrCreate(in context: NSManagedObjectContext, by dictionary: KeyObjectDictionary?) throws -> Self {
        return try findFirst(in: context, with: dictionary?.asPredicate(with: .and)) ?? create(in: context, applying: dictionary)
    }

    /// Safely accessess the given KeyPath on the objects managedObjectContext.
    /// If no managedObjectContext is there, it directly accesses the property.
    public subscript<T>(safe keyPath: ReferenceWritableKeyPath<Self, T>) -> T {
        get {
            if let moc = managedObjectContext {
                return moc.sync { self[keyPath: keyPath] }
            } else {
                return self[keyPath: keyPath]
            }
        }
        set {
            if let moc = managedObjectContext {
                moc.sync { self[keyPath: keyPath] = newValue }
            } else {
                self[keyPath: keyPath] = newValue
            }
        }
    }

    public subscript<T>(safe keyPath: KeyPath<Self, T>) -> T {
        if let moc = managedObjectContext {
            return moc.sync { self[keyPath: keyPath] }
        } else {
            return self[keyPath: keyPath]
        }
    }
}

extension NSManagedObject {
    @usableFromInline
    @nonobjc
    internal static var shouldRemoveNamespaceInEntityName: Bool = true
}

public enum FindOrCreatableError: Error, Equatable, CustomStringConvertible {
    case invalidEntity(entityName: String)

    public var description: String {
        switch self {
        case .invalidEntity(let entityName):
            return "Invalid entity with name \"\(entityName)\""
        }
    }
}

extension NSManagedObjectContext {
    public final func sync<T>(do work: () throws -> T) rethrows -> T {
        return try {
            var result: Result<T, Error>!
            performAndWait {
                result = Result(catching: work)
            }
            return try result.get()
            }()
    }

    @inlinable
    public final func async(do work: @escaping () -> ()) {
        perform(work)
    }
}
