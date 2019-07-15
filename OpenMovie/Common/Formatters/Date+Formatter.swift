//
//  Date+Formatter.swift
//  OpenMovie
//
//  Created by Anthony Soulier on 12/07/2019.
//  Copyright © 2019 Anthony Soulier. All rights reserved.
//

import Foundation

struct Formatters {
    struct Date {
        static let shortDate: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .none
            return formatter
        }()
    }
}

extension Date {
    var shortDate: String {
        return Formatters.Date.shortDate.string(from: self)
    }
}
