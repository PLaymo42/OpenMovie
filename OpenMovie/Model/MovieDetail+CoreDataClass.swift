//
//  MovieDetail+CoreDataClass.swift
//  OpenMovie
//
//  Created by Anthony Soulier on 13/07/2019.
//  Copyright © 2019 Anthony Soulier. All rights reserved.
//
//

import Foundation
import CoreData

@objc(MovieDetail)
public final class MovieDetail: NSManagedObject, CoreDataDecodable, FindOrCreatable, Fetchable {

    enum CodingKeys: String, CodingKey {
        case budget
        case id
    }

    static func createOrUpdate(from object: Any, in context: NSManagedObjectContext) throws -> MovieDetail {

        guard let dict = object as? [String: Any] else {
            throw DataDecodingError.malformedJSON
        }

        let id = try dict.decode(Int64.self, forKey: CodingKeys.id)
        guard let movieDetails = try? MovieDetail.findFirst(in: context, with: NSPredicate(format: "id == %i", id)) ?? MovieDetail(entity: MovieDetail.entity(), insertInto: context) else {
            throw CoreDataError.unableToCreate
        }

        movieDetails.id = id
        movieDetails.budget = try dict.decode(Int64.self, forKey: CodingKeys.budget)

        movieDetails.movie = try? Movie.findFirst(in: context, with: NSPredicate(format: "id == %i", id))

        return movieDetails
    }
}
