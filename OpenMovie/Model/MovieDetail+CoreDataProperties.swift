//
//  MovieDetail+CoreDataProperties.swift
//  OpenMovie
//
//  Created by Anthony Soulier on 29/08/2019.
//  Copyright © 2019 Anthony Soulier. All rights reserved.
//
//

import Foundation
import CoreData


extension MovieDetail {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MovieDetail> {
        return NSFetchRequest<MovieDetail>(entityName: "MovieDetail")
    }

    @NSManaged public var budget: Int64
    @NSManaged public var id: Int64
    @NSManaged public var movie: Movie?

}
