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

    private var memCache: [String: UIImage] = [:]

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
                return "https://image.tmdb.org/t/p/w154/"
            case .medium:
                return "https://image.tmdb.org/t/p/w500/"
            case .cast:
                return "https://image.tmdb.org/t/p/w185/"
            case .original:
                return "https://image.tmdb.org/t/p/original/"
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
        memCache.removeAll()
    }

    func syncImageFromCache(poster: String, size: Size) -> UIImage? {
        return memCache[poster]
    }

    // TODO: Prefix memcache with poster size.
    func image(poster: String, size: Size) -> AnyPublisher<UIImage?, Error> {

        if let cachedImage = memCache[poster] {
            return Publishers.Once(cachedImage).eraseToAnyPublisher()
        }

        return self.urlSession.dataTaskPublisher(for: size.path(poster: poster))
            .publisher(for: \.data)
            .tryMap {
                guard let image = UIImage(data: $0) else {
                    throw ImageError.decodingError
                }
                return image
        }
        .eraseToAnyPublisher()
    }
}

