//
//  NSFetchedResultsController+Combine.swift
//  OpenMovie
//
//  Created by Anthony Soulier on 09/07/2019.
//  Copyright © 2019 Anthony Soulier. All rights reserved.
//

import Foundation
import CoreData
import Combine


/// Sends all objects which match fetchRequest per demand.
/// First demand will be send immediately, subsequent demands will be filled when there is an update in database.
public class NSFetchedResultsPublisher<ResultType: NSFetchRequestResult>: Publisher {
    public typealias Output = [ResultType]
    public typealias Failure = Error


    private let fetchRequest: NSFetchRequest<ResultType>
    private let managedObjectContext: NSManagedObjectContext
    private let sectionNameKeyPath: String?
    private let cacheName: String?

    public init(fetchRequest: NSFetchRequest<ResultType>,
                managedObjectContext: NSManagedObjectContext,
                sectionNameKeyPath: String? = nil,
                cacheName: String? = nil) {
        self.fetchRequest = fetchRequest
        self.managedObjectContext = managedObjectContext
        self.sectionNameKeyPath = sectionNameKeyPath
        self.cacheName = cacheName
    }

    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = FetchedResultsSubscription(fetchRequest: fetchRequest,
                                                      managedObjectContext: managedObjectContext,
                                                      sectionNameKeyPath: sectionNameKeyPath,
                                                      cacheName: cacheName,
                                                      receiveCompletion: subscriber.receive(completion:),
                                                      receiveValue: subscriber.receive(_:))
        subscriber.receive(subscription: subscription)
    }
}

public enum FetchedResultsError: Error {
    case cannotConvertValue(NSFetchRequestResult)
}

private class FetchedResultsSubscription<ResultType: NSFetchRequestResult>: NSObject, Subscription, NSFetchedResultsControllerDelegate {

    private enum State {
        case waitingForDemand
        case observing(NSFetchedResultsController<ResultType>, Subscribers.Demand)
        case completed
        case cancelled
    }

    private var state: State

    private let fetchRequest: NSFetchRequest<ResultType>
    private let managedObjectContext: NSManagedObjectContext
    private let sectionNameKeyPath: String?
    private let cacheName: String?
    private let receiveCompletion: (Subscribers.Completion<Error>) -> Void
    private let receiveValue: ([ResultType]) -> Subscribers.Demand

    init(
        fetchRequest: NSFetchRequest<ResultType>,
        managedObjectContext: NSManagedObjectContext,
        sectionNameKeyPath: String?,
        cacheName: String?,
        receiveCompletion: @escaping (Subscribers.Completion<Error>) -> Void,
        receiveValue: @escaping ([ResultType]) -> Subscribers.Demand)
    {
        self.state = .waitingForDemand
        self.fetchRequest = fetchRequest
        self.managedObjectContext = managedObjectContext
        self.sectionNameKeyPath = sectionNameKeyPath
        self.cacheName = cacheName
        self.receiveCompletion = receiveCompletion
        self.receiveValue = receiveValue
        super.init()
    }

    func request(_ demand: Subscribers.Demand) {
        func createdFetchedResultsController() -> NSFetchedResultsController<ResultType> {
            NSFetchedResultsController(
                fetchRequest: self.fetchRequest,
                managedObjectContext: self.managedObjectContext,
                sectionNameKeyPath: self.sectionNameKeyPath,
                cacheName: self.cacheName
            )
        }

        switch state {
        case .waitingForDemand:
            guard demand > 0 else {
                return
            }
            let fetchedResultsController = createdFetchedResultsController()
            fetchedResultsController.delegate = self
            state = .observing(fetchedResultsController, demand)

            do {
                try fetchedResultsController.performFetch()
                receiveUpdatedValues()
            } catch {
                receiveCompletion(.failure(error))
            }
        case .observing(let fetchedResultsController, let currentDemand):
            state = .observing(fetchedResultsController, currentDemand + demand)
        case .completed:
            break
        case .cancelled:
            break
        }
    }

    func cancel() {
        state = .cancelled
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard case .observing = state else {
            return
        }
        receiveUpdatedValues()
    }

    private func receiveUpdatedValues() {
        guard case .observing(let fetchedResultsController, let demand) = state else {
            return
        }

        let additionalDemand = receiveValue(fetchedResultsController.fetchedObjects ?? [])

        let newDemand = demand + additionalDemand - 1
        if newDemand == .none {
            fetchedResultsController.delegate = nil
            state = .waitingForDemand
        } else {
            state = .observing(fetchedResultsController, newDemand)
        }
    }

    private func receiveCompletion(_ completion: Subscribers.Completion<Error>) {
        guard case .observing = state else {
            return
        }

        state = .completed
        receiveCompletion(completion)
    }
}


public class NSFetchedSingleResultsPublisher<ResultType: NSFetchRequestResult>: Publisher {
    public typealias Output = ResultType?
    public typealias Failure = Error


    private let fetchRequest: NSFetchRequest<ResultType>
    private let managedObjectContext: NSManagedObjectContext
    private let sectionNameKeyPath: String?
    private let cacheName: String?

    public init(fetchRequest: NSFetchRequest<ResultType>,
                managedObjectContext: NSManagedObjectContext,
                sectionNameKeyPath: String? = nil,
                cacheName: String? = nil) {
        self.fetchRequest = fetchRequest
        self.managedObjectContext = managedObjectContext
        self.sectionNameKeyPath = sectionNameKeyPath
        self.cacheName = cacheName
    }

    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = FetchedSingleResultsSubscription(
            fetchRequest: fetchRequest,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: sectionNameKeyPath,
            cacheName: cacheName,
            receiveCompletion: subscriber.receive(completion:),
            receiveValue: subscriber.receive(_:)
        )
        subscriber.receive(subscription: subscription)
    }
}

private class FetchedSingleResultsSubscription<ResultType: NSFetchRequestResult>: NSObject, Subscription, NSFetchedResultsControllerDelegate {

    private enum State {
        case waitingForDemand
        case observing(NSFetchedResultsController<ResultType>, Subscribers.Demand)
        case completed
        case cancelled
    }

    private var state: State

    private let fetchRequest: NSFetchRequest<ResultType>
    private let managedObjectContext: NSManagedObjectContext
    private let sectionNameKeyPath: String?
    private let cacheName: String?
    private let receiveCompletion: (Subscribers.Completion<Error>) -> Void
    private let receiveValue: (ResultType?) -> Subscribers.Demand

    init(
        fetchRequest: NSFetchRequest<ResultType>,
        managedObjectContext: NSManagedObjectContext,
        sectionNameKeyPath: String?,
        cacheName: String?,
        receiveCompletion: @escaping (Subscribers.Completion<Error>) -> Void,
        receiveValue: @escaping (ResultType?) -> Subscribers.Demand)
    {
        self.state = .waitingForDemand
        self.fetchRequest = fetchRequest
        self.managedObjectContext = managedObjectContext
        self.sectionNameKeyPath = sectionNameKeyPath
        self.cacheName = cacheName
        self.receiveCompletion = receiveCompletion
        self.receiveValue = receiveValue
        super.init()
    }

    func request(_ demand: Subscribers.Demand) {
        func createdFetchedResultsController() -> NSFetchedResultsController<ResultType> {
            NSFetchedResultsController(
                fetchRequest: self.fetchRequest,
                managedObjectContext: self.managedObjectContext,
                sectionNameKeyPath: self.sectionNameKeyPath,
                cacheName: self.cacheName
            )
        }

        switch state {
        case .waitingForDemand:
            guard demand > 0 else {
                return
            }
            let fetchedResultsController = createdFetchedResultsController()
            fetchedResultsController.delegate = self
            state = .observing(fetchedResultsController, demand)

            do {
                try fetchedResultsController.performFetch()
                receiveUpdatedValues()
            } catch {
                receiveCompletion(.failure(error))
            }
        case .observing(let fetchedResultsController, let currentDemand):
            state = .observing(fetchedResultsController, currentDemand + demand)
        case .completed:
            break
        case .cancelled:
            break
        }
    }

    func cancel() {
        state = .cancelled
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard case .observing = state else {
            return
        }
        receiveUpdatedValues()
    }

    private func receiveUpdatedValues() {
        guard case .observing(let fetchedResultsController, let demand) = state else {
            return
        }

        let additionalDemand = receiveValue(fetchedResultsController.fetchedObjects?.first)

        let newDemand = demand + additionalDemand - 1
        if newDemand == .none {
            fetchedResultsController.delegate = nil
            state = .waitingForDemand
        } else {
            state = .observing(fetchedResultsController, newDemand)
        }
    }

    private func receiveCompletion(_ completion: Subscribers.Completion<Error>) {
        guard case .observing = state else {
            return
        }

        state = .completed
        receiveCompletion(completion)
    }
}
