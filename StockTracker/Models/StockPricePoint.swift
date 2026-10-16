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

    var id: Date {
        date
    }
}
