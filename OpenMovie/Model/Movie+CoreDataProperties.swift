//
//  Movie+CoreDataProperties.swift
//  OpenMovie
//
//  Created by Anthony Soulier on 29/08/2019.
//  Copyright © 2019 Anthony Soulier. All rights reserved.
//
//

import Foundation
import CoreData


extension Movie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Movie> {
        return NSFetchRequest<Movie>(entityName: "Movie")
    }

    @NSManaged public var backdropPath: String?
    @NSManaged public var hasVideo: Bool
    @NSManaged public var id: Int64
    @NSManaged public var isFavorite: Bool
    @NSManaged public var isForAdult: Bool
    @NSManaged public var overview: String?
    @NSManaged public var popularity: Float
    @NSManaged public var posterPath: String?
    @NSManaged public var releaseDate: Date?
    @NSManaged public var title: String?
    @NSManaged public var voteAverage: Float
    @NSManaged public var voteCount: Int64
    @NSManaged public var detail: MovieDetail?
    @NSManaged public var images: MovieImage?

}
