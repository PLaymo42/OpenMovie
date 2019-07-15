//
//  MovieDatabaseAPI.swift
//  OpenMovie
//
//  Created by Anthony Soulier on 28/06/2019.
//  Copyright © 2019 Anthony Soulier. All rights reserved.
//

import Foundation

protocol MovieDatabaseAPI: API {
    var apiKey: String { get }
    var defaultParameters: [String: String] { get }
}

extension MovieDatabaseAPI {

    var baseURL: URL {
        return URL(string: "https://api.themoviedb.org/3")!
    }

    var apiKey: String {
        return "bffa20b09c94dd929c0034e3069b5120"
    }

    var defaultParameters: [String: String] {
        return [:]
//        return ["language": Locale.current.languageCode ?? "en-US"]
    }

    var url: URL {
        let url = baseURL.appendingPathComponent(path)

        guard var urlComponents = URLComponents(string: url.absoluteString) else { return url }

        // Create array of existing query items
        var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []

        // Create query item
        let queryItem = URLQueryItem(name: "api_key", value: self.apiKey)
        // Append the new query item in the existing query items array
        queryItems.append(queryItem)

        if case let .pathParameters(parameters) = self.parameters {
            let items = parameters.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
            queryItems.append(contentsOf: items)
        }


        let items = self.defaultParameters.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
        queryItems.append(contentsOf: items)

        // Append updated query items array in the url component object
        urlComponents.queryItems = queryItems

        // Returns the url from new url components
        return urlComponents.url!
    }
}
