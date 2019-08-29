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
public final class Movie: NSManagedObject, Identifiable, CoreDataDecodable, FindOrCreatable {

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
    
    override public func willChangeValue(forKey key: String) {
        super.willChangeValue(forKey: key)
        self.objectWillChange.send()
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
