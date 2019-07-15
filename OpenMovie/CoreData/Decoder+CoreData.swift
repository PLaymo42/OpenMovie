//
//  Decoder+CoreData.swift
//  OpenMovie
//
//  Created by Anthony Soulier on 08/07/2019.
//  Copyright © 2019 Anthony Soulier. All rights reserved.
//

import Foundation
import CoreData
import Combine

enum DataDecodingError: Error {
    case malformedJSON
}

extension CodingUserInfoKey {
    static let context = CodingUserInfoKey(rawValue: "context")!
}

protocol CoreDataDecodable {
    static func createOrUpdate(from object: Any, in context: NSManagedObjectContext) throws -> Self
}

enum CoreDataError: Error {
    case unableToCreate
}

extension Array: CoreDataDecodable where Element: CoreDataDecodable {

    static func createOrUpdate(from object: Any, in context: NSManagedObjectContext) throws -> [Element] {

        guard let array = object as? [[String: Any]] else {
            throw DataDecodingError.malformedJSON
        }

        return try array.map {
            try Element.createOrUpdate(from: $0, in: context)
        }
    }
}

extension Decoder {
    var persistentContainer: NSPersistentContainer {
        guard let persistentContainer = self.userInfo[.context] as? NSPersistentContainer else { fatalError("cannot Retrieve context") }
        return persistentContainer
    }

    var managedObjectContext: NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }
}

extension JSONDecoder {
    var persistentContainer: NSPersistentContainer {
        guard let persistentContainer = self.userInfo[.context] as? NSPersistentContainer else { fatalError("cannot Retrieve context") }
        return persistentContainer
    }

    var managedObjectContext: NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }
}
