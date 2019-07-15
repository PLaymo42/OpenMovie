//
//  URLFileDataProvider.swift
//  PulseLive
//
//  Created by Anthony Soulier on 22/03/2019.
//  Copyright © 2019 Anthony Soulier. All rights reserved.
//

import Foundation
import Combine
import CoreData

class DataProvider<U> where U: API {

    private let session: URLSession

    init(session: URLSession = URLSession.shared) {
        self.session = session
    }

    func fetchData<T>(target: U) -> AnyPublisher<T, Error> where T: CoreDataDecodable {

        let decoder = target.decoder

        decoder.userInfo[.context] = Dependencies.shared.persistentContainer

        return session
            .dataTaskPublisher(for: target.url)
            .publisher(for: \.data)
            .receive(on: RunLoop.main)
            .decode(type: T.self, decoder: decoder, keyPath: target.keyPath)
    }
}

extension Publisher where Output == Data {

    func decodeCreateOrUpdate<Item, Coder>(type: Item.Type, decoder: Coder) -> AnyPublisher<Item, Error> where Item: CoreDataDecodable, Coder: JSONDecoder, Self.Output == Coder.Input {

        return self.tryMap {
            let toplevel = try JSONSerialization.jsonObject(with: $0)
            return try Item.createOrUpdate(from: toplevel, in: decoder.managedObjectContext)
        }
        .eraseToAnyPublisher()
    }


    func decode<Item, Coder>(type: Item.Type, decoder: Coder, keyPath: String?) -> AnyPublisher<Item, Error> where Item: CoreDataDecodable, Coder: JSONDecoder, Self.Output == Coder.Input {

        return self.tryMap {

            guard let keyPath = keyPath else { return $0 }

            let toplevel = try JSONSerialization.jsonObject(with: $0)
            if let nestedJson = (toplevel as AnyObject).value(forKeyPath: keyPath) {
                return try JSONSerialization.data(withJSONObject: nestedJson)
            } else {
                throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Nested json not found for key path \"\(keyPath)\""))
            }
        }
        .decodeCreateOrUpdate(type: Item.self, decoder: decoder)
        .eraseToAnyPublisher()
    }
}
