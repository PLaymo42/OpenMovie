//
//  Movie+CoreDataClass.swift
//  OpenMovie
//
//  Created by Anthony Soulier on 08/07/2019.
//  Copyright © 2019 Anthony Soulier. All rights reserved.
//
//

import Foundation
import CoreData
import SwiftUI
import Combine


@objc(Movie)
public final class Movie: NSManagedObject, BindableObject, CoreDataDecodable, FindOrCreatable {

    enum CodingKeys: String, CodingKey {
        case voteAverage = "vote_average"
        case popularity
        case title
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case isForAdult = "adult"
        case overview
        case releaseDate = "release_date"
        case id
        case voteCount = "vote_count"
        case hasVideo = "video"
    }

    public let didChange = PassthroughSubject<Void, Never>()

    public override func didChangeValue(forKey key: String) {
        super.didChangeValue(forKey: key)
        DispatchQueue.main.async {
            self.didChange.send(())
        }
    }

    func getOrCreate(context: NSManagedObjectContext) -> Movie? {
        return try? Movie.findFirst(in: context, with: NSPredicate(format: "id == %i", self.id))
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static func createOrUpdate(from object: Any, in context: NSManagedObjectContext) throws -> Movie {

        guard let dict = object as? [String: Any] else {
            throw DataDecodingError.malformedJSON
        }

        let id = try dict.decode(Int64.self, forKey: CodingKeys.id)
        guard let movie = try? Movie.findFirst(in: context, with: NSPredicate(format: "id == %i", id)) ?? Movie(entity: Movie.entity(), insertInto: context) else {
            throw CoreDataError.unableToCreate
        }

        movie.id = id
        movie.popularity = try dict.decode(Float.self, forKey: CodingKeys.popularity)
        movie.voteAverage = try dict.decode(Float.self, forKey: CodingKeys.voteAverage)
        movie.title = try dict.decode(String.self, forKey: CodingKeys.title)
        movie.posterPath = try? dict.decode(String.self, forKey: CodingKeys.posterPath)
        movie.backdropPath = try? dict.decode(String.self, forKey: CodingKeys.backdropPath)
        movie.isForAdult = try dict.decode(Bool.self, forKey: CodingKeys.isForAdult)
        movie.overview = try dict.decode(String.self, forKey: CodingKeys.overview)
        movie.releaseDate = try dict.decode(Date.self, forKey: CodingKeys.releaseDate, using: self.dateFormatter)
        movie.voteCount = try dict.decode(Int64.self, forKey: CodingKeys.voteCount)
        movie.hasVideo = try dict.decode(Bool.self, forKey: CodingKeys.hasVideo)

        return movie
    }
}

extension Dictionary where Key == String, Value: Any {

    func decode<T>(_ type: T.Type, forKey key: CodingKey) throws -> T {
        guard let value = self[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: [key], debugDescription: "No value associated with key \(key)."))
        }

        guard let typed = value as? T else {
            throw DecodingError.typeMismatch(T.self, DecodingError.Context(codingPath: [key], debugDescription: "Type mismatch for key \(key)."))
        }
        return typed
    }

    func decode(_ type: Float.Type, forKey key: CodingKey) throws -> Float {
        guard let value = self[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: [key], debugDescription: "No value associated with key \(key)."))
        }

        guard let typed = (value as? NSNumber)?.floatValue else {
            throw DecodingError.typeMismatch(Float.self, DecodingError.Context(codingPath: [key], debugDescription: "Type mismatch for key \(key)."))
        }
        return typed
    }

    func decode(_ type: Double.Type, forKey key: CodingKey) throws -> Double {
        guard let value = self[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: [key], debugDescription: "No value associated with key \(key)."))
        }

        guard let typed = (value as? NSNumber)?.doubleValue else {
            throw DecodingError.typeMismatch(Double.self, DecodingError.Context(codingPath: [key], debugDescription: "Type mismatch for key \(key)."))
        }
        return typed
    }


    func decode<T: FixedWidthInteger>(_ type: T.Type, forKey key: CodingKey) throws -> T {
        guard let value = self[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: [key], debugDescription: "No value associated with key \(key)."))
        }

        guard let typed = value as? Int else {
            throw DecodingError.typeMismatch(Int8.self, DecodingError.Context(codingPath: [key], debugDescription: "Type mismatch for key \(key)."))
        }
        return T.init(typed)
    }

    func decode(_ type: Date.Type, forKey key: CodingKey, using dateFormatter: DateFormatter) throws -> Date {
        guard let value = self[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: [key], debugDescription: "No value associated with key \(key)."))
        }

        guard let string = value as? String,
            let date = dateFormatter.date(from: string) else {
            throw DecodingError.typeMismatch(Date.self, DecodingError.Context(codingPath: [key], debugDescription: "Type mismatch for key \(key)."))
        }
        return date
    }

}
