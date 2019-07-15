//
//  API.swift
//  PulseLive
//
//  Created by Anthony Soulier on 22/03/2019.
//  Copyright © 2019 Anthony Soulier. All rights reserved.
//

import Foundation

enum Task {
    case none
    case pathParameters([String: String])
}

enum ParameterEncoding {
    case urlEncoding
}

protocol API {
    var baseURL: URL { get }
    var path: String { get }
    var url: URL { get }
    var parameters: Task { get }

    var decoder: JSONDecoder { get }
    var keyPath: String? { get }
}


extension API {

    var url: URL {
        let url = baseURL.appendingPathComponent(path)

        guard var urlComponents = URLComponents(string: url.absoluteString) else { return url }

        // Create array of existing query items
        var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []


        if case let .pathParameters(parameters) = self.parameters {
            let items = parameters.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
            queryItems.append(contentsOf: items)
        }

        // Append updated query items array in the url component object
        urlComponents.queryItems = queryItems

        // Returns the url from new url components
        return urlComponents.url!
    }

    var parameters: Task {
        return .none
    }

    var decoder: JSONDecoder {
        return JSONDecoder()
    }

    var keyPath: String? {
        return nil
    }
}
