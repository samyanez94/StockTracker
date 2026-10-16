//
//  StockPricePoint.swift
//  StockTracker
//
//  Created by Samuel Yanez on 10/16/26.
//

import Foundation

/// A closing price at the opening timestamp of a five-minute trading bar.
nonisolated struct StockPricePoint: Identifiable, Equatable, Sendable {
    let date: Date
    let price: Double
    let timeZone: TimeZone

    init(date: Date, price: Double, timeZone: TimeZone = .gmt) {
        self.date = date
        self.price = price
        self.timeZone = timeZone
    }

    var id: Date {
        date
    }
}
