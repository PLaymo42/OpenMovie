//
//  MovieAPI.swift
//  OpenMovie
//
//  Created by Anthony Soulier on 22/03/2019.
//  Copyright © 2019 Anthony Soulier. All rights reserved.
//

import Foundation

enum MovieApi {
    case currentlyInTheater
    case detail(Int)
    case images(Int)
}

extension MovieApi: MovieDatabaseAPI {
    var path: String {
        switch self {
        case .currentlyInTheater:
            return "movie/now_playing"
        case let .detail(id):
            return "/movie/\(id)"
        case let .images(id):
            return "/movie/\(id)/images"
        }
    }

    var keyPath: String? {
        switch self {
        case .currentlyInTheater:
            return "results"
        default:
            return nil
        }
    }
    
}
