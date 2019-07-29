//
//  Dictionnayr+Decode.swift
//  OpenMovie
//
//  Created by Anthony Soulier on 29/07/2019.
//  Copyright © 2019 Anthony Soulier. All rights reserved.
//

import Foundation

extension Dictionary where Key == String, Value: Any {

    func decode<T>(_ type: T.Type, forKey key: CodingKey) throws -> T {
        guard let value = self[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: [key], debugDescription: "No value associated with key \(key)."))
        }

        guard let typed = value as? T else {
            throw DecodingError.typeMismatch(T.self, DecodingError.Context(codingPath: [key], debugDescription: "Type mismatch for key \(key)."))
        }
        return typed
    }

    func decode(_ type: Float.Type, forKey key: CodingKey) throws -> Float {
        guard let value = self[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: [key], debugDescription: "No value associated with key \(key)."))
        }

        guard let typed = (value as? NSNumber)?.floatValue else {
            throw DecodingError.typeMismatch(Float.self, DecodingError.Context(codingPath: [key], debugDescription: "Type mismatch for key \(key)."))
        }
        return typed
    }

    func decode(_ type: Double.Type, forKey key: CodingKey) throws -> Double {
        guard let value = self[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: [key], debugDescription: "No value associated with key \(key)."))
        }

        guard let typed = (value as? NSNumber)?.doubleValue else {
            throw DecodingError.typeMismatch(Double.self, DecodingError.Context(codingPath: [key], debugDescription: "Type mismatch for key \(key)."))
        }
        return typed
    }


    func decode<T: FixedWidthInteger>(_ type: T.Type, forKey key: CodingKey) throws -> T {
        guard let value = self[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: [key], debugDescription: "No value associated with key \(key)."))
        }

        guard let typed = value as? Int else {
            throw DecodingError.typeMismatch(Int8.self, DecodingError.Context(codingPath: [key], debugDescription: "Type mismatch for key \(key)."))
        }
        return T.init(typed)
    }

    func decode(_ type: Date.Type, forKey key: CodingKey, using dateFormatter: DateFormatter) throws -> Date {
        guard let value = self[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: [key], debugDescription: "No value associated with key \(key)."))
        }

        guard let string = value as? String,
            let date = dateFormatter.date(from: string) else {
            throw DecodingError.typeMismatch(Date.self, DecodingError.Context(codingPath: [key], debugDescription: "Type mismatch for key \(key)."))
        }
        return date
    }

}
