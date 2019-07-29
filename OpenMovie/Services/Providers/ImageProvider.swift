//
//  ImageProvider.swift
//  OpenMovie
//
//  Created by Anthony Soulier on 02/07/2019.
//  Copyright © 2019 Anthony Soulier. All rights reserved.
//

import Combine
import SwiftUI
import UIKit

class ImageService {

    static let shared = ImageService()

    private var memCache = NSCache<NSString, UIImage>()

    private let urlSession: URLSession

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    enum Size: String {
        case small
        case medium
        case cast
        case original

        private var prefix: String {
            switch self {
            case .small:
                return "https://image.tmdb.org/t/p/w154"
            case .medium:
                return "https://image.tmdb.org/t/p/w500"
            case .cast:
                return "https://image.tmdb.org/t/p/w185"
            case .original:
                return "https://image.tmdb.org/t/p/original"
            }
        }

        func path(poster: String) -> URL {
            return URL(string: self.prefix)!.appendingPathComponent(poster)
        }
    }

    enum ImageError: Error {
        case decodingError
    }

    func purgeCache() {
        memCache.removeAllObjects()
    }

    func fromCache(poster: String, size: Size) -> UIImage? {
        let key = size.path(poster: poster).absoluteString as NSString
        return memCache.object(forKey: key)
    }

    func image(poster: String, size: Size) -> AnyPublisher<UIImage?, Error> {

        if let cachedImage = self.fromCache(poster: poster, size: size) {
            return Result.success(cachedImage)
                .publisher
                .eraseToAnyPublisher()
        }

        let path = size.path(poster: poster)

        return self.urlSession
            .dataTaskPublisher(for: path)
            .tryMap {
                guard let image = UIImage(data: $0.data) else {
                    throw ImageError.decodingError
                }
                self.memCache.setObject(image, forKey: path.absoluteString as NSString)
                return image
            }
            .eraseToAnyPublisher()
    }
}

