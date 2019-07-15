//
//  JSONDecoder+Extension.swift
//  PulseLive
//
//  Created by Anthony Soulier on 22/03/2019.
//  Copyright © 2019 Anthony Soulier. All rights reserved.
//

import Foundation

extension JSONDecoder {
    static func decoder(dateFormat: String) -> JSONDecoder {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .custom { decoder -> Date in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            let formatter = DateFormatter()
            formatter.dateFormat = dateFormat

            guard let date = formatter.date(from: dateString) else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Cannot decode date string \(dateString)"
                )
            }

            return date
        }

        return jsonDecoder
    }
}
