//
//  ImageInfo+CoreDataProperties.swift
//  OpenMovie
//
//  Created by Anthony Soulier on 29/08/2019.
//  Copyright © 2019 Anthony Soulier. All rights reserved.
//
//

import Foundation
import CoreData


extension ImageInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImageInfo> {
        return NSFetchRequest<ImageInfo>(entityName: "ImageInfo")
    }

    @NSManaged public var aspectRatio: Double
    @NSManaged public var filePath: String?
    @NSManaged public var height: Int16
    @NSManaged public var width: Int16
    @NSManaged public var backdrop: ImageInfo?
    @NSManaged public var poster: ImageInfo?

}
