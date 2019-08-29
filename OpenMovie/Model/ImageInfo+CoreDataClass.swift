//
//  ImageInfo+CoreDataClass.swift
//  OpenMovie
//
//  Created by Anthony Soulier on 14/07/2019.
//  Copyright © 2019 Anthony Soulier. All rights reserved.
//
//

import Foundation
import CoreData
import SwiftUI

@objc(ImageInfo)
public final class ImageInfo: NSManagedObject, CoreDataDecodable, FindOrCreatable, Fetchable, Identifiable {

    enum CodingKeys: String, CodingKey {
        case aspectRatio = "aspect_ratio"
        case filePath = "file_path"
        case height = "height"
        case width = "width"
    }

    static func createOrUpdate(from object: Any, in context: NSManagedObjectContext) throws -> ImageInfo {

        guard let dict = object as? [String: Any] else {
            throw DataDecodingError.malformedJSON
        }

        let filePath = try dict.decode(String.self, forKey: CodingKeys.filePath)

        guard let info = try? ImageInfo.findFirst(in: context, with: NSPredicate(format: "filePath == %@", filePath)) ?? ImageInfo(entity: ImageInfo.entity(), insertInto: context) else {
            throw CoreDataError.unableToCreate
        }

        info.filePath = filePath
        info.aspectRatio = try dict.decode(Double.self, forKey: CodingKeys.aspectRatio)
        info.height = try dict.decode(Int16.self, forKey: CodingKeys.height)
        info.width = try dict.decode(Int16.self, forKey: CodingKeys.width)

        return info
    }

    var ratio: CGFloat {
        return CGFloat(height) / CGFloat(width)
    }
}
