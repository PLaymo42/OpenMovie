//
//  MovieImage+CoreDataClass.swift
//  OpenMovie
//
//  Created by Anthony Soulier on 14/07/2019.
//  Copyright © 2019 Anthony Soulier. All rights reserved.
//
//

import Foundation
import CoreData

@objc(MovieImage)
public final class MovieImage: NSManagedObject, CoreDataDecodable, FindOrCreatable, Fetchable {

    enum CodingKeys: String, CodingKey {
        case posters
        case backdrops
        case id
    }

    static func getOrCreate(id: Int64, in context: NSManagedObjectContext) throws -> MovieImage {
        guard let image =
            try? MovieImage.findFirst(in: context, with: NSPredicate(format: "id == %i", id)) ??
                MovieImage(entity: MovieImage.entity(), insertInto: context)
            else {
                throw CoreDataError.unableToCreate
        }

        return image
    }

    static func createOrUpdate(from object: Any, in context: NSManagedObjectContext) throws -> MovieImage {

        guard let dict = object as? [String: Any] else {
            throw DataDecodingError.malformedJSON
        }

        let id = try dict.decode(Int64.self, forKey: CodingKeys.id)

        guard let movie = try Movie.findFirst(in: context, with: NSPredicate(format: "id == %i", id)) else {
            throw DataDecodingError.malformedJSON
        }

        let image = try MovieImage.getOrCreate(id: id, in: context)

        image.id = id

        let backdropsDict = dict[CodingKeys.backdrops.stringValue] as? [Any]
        let backdrops = try backdropsDict?.map {
            try ImageInfo.createOrUpdate(from: $0, in: context)
        } ?? []
        image.backdrops = []
        image.addToBackdrops(NSSet(array: backdrops))

        let posters = try (dict[CodingKeys.posters.stringValue] as? [Any])?.map {
            try ImageInfo.createOrUpdate(from: $0, in: context)
            } ?? []

        image.posters = []
        image.addToPosters(NSSet(array: posters))


        movie.images = image

        return image
    }

}
