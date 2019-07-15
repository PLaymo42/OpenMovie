//
//  MovieImage+CoreDataProperties.swift
//  OpenMovie
//
//  Created by Anthony Soulier on 14/07/2019.
//  Copyright © 2019 Anthony Soulier. All rights reserved.
//
//

import Foundation
import CoreData


extension MovieImage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MovieImage> {
        return NSFetchRequest<MovieImage>(entityName: "MovieImage")
    }

    @NSManaged public var id: Int64
    @NSManaged public var backdrops: NSSet?
    @NSManaged public var posters: NSSet?
    @NSManaged public var movie: Movie?

}

// MARK: Generated accessors for backdrops
extension MovieImage {

    @objc(addBackdropsObject:)
    @NSManaged public func addToBackdrops(_ value: ImageInfo)

    @objc(removeBackdropsObject:)
    @NSManaged public func removeFromBackdrops(_ value: ImageInfo)

    @objc(addBackdrops:)
    @NSManaged public func addToBackdrops(_ values: NSSet)

    @objc(removeBackdrops:)
    @NSManaged public func removeFromBackdrops(_ values: NSSet)

}

// MARK: Generated accessors for posters
extension MovieImage {

    @objc(addPostersObject:)
    @NSManaged public func addToPosters(_ value: ImageInfo)

    @objc(removePostersObject:)
    @NSManaged public func removeFromPosters(_ value: ImageInfo)

    @objc(addPosters:)
    @NSManaged public func addToPosters(_ values: NSSet)

    @objc(removePosters:)
    @NSManaged public func removeFromPosters(_ values: NSSet)

}
