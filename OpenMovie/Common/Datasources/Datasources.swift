//
//  Datasource.swift
//  OpenMovie
//
//  Created by Anthony Soulier on 11/07/2019.
//  Copyright © 2019 Anthony Soulier. All rights reserved.
//

import Foundation
import Combine
import CoreData

class SingleResultDataSource<U, T> where U: API, T: CoreDataDecodable, T: Fetchable {

    private let context: NSManagedObjectContext
    private let predicate: NSPredicate?

    init(predicate: NSPredicate? = nil,
         context: NSManagedObjectContext = Dependencies.shared.managedObjectContext) {
        self.context = context
        self.predicate = predicate
    }

    let requestProvider = DataProvider<U>()

    lazy var coreDataPublisher = NSFetchedSingleResultsPublisher<T>(
        fetchRequest: T.fetchRequest(with: self.predicate, sortedBy: []),
        managedObjectContext: self.context
    )

    func publisher(for target: U) -> AnyPublisher<T?, Error> {

        let requestPublisher = self.requestProvider
            .fetchData(target: target)
            .map { return Optional<T>($0) }

        return Publishers.Merge(coreDataPublisher, requestPublisher)
            .eraseToAnyPublisher()
        
        return requestPublisher.eraseToAnyPublisher()
    }
}

class DataSource<U, T> where U: API, T: CoreDataDecodable, T: Fetchable {

    private let context: NSManagedObjectContext

    private let predicate: NSPredicate?
    private let sortDescriptor: [NSSortDescriptor]?

    init(predicate: NSPredicate? = nil,
         sortDescriptor: [NSSortDescriptor]? = [],
        context: NSManagedObjectContext = Dependencies.shared.managedObjectContext) {
        self.context = context
        self.predicate = predicate
        self.sortDescriptor = sortDescriptor
    }

    let requestProvider = DataProvider<U>()

    lazy var coreDataPublisher = NSFetchedResultsPublisher<T>(
        fetchRequest: T.fetchRequest(with: self.predicate, sortedBy: self.sortDescriptor),
        managedObjectContext: self.context
    )

    func publisher(for target: U) -> AnyPublisher<[T], Error> {

        let requestPublisher: AnyPublisher<[T], Error> = self.requestProvider.fetchData(target: target)

        return Publishers.Merge(coreDataPublisher, requestPublisher)
            .eraseToAnyPublisher()
    }
}
