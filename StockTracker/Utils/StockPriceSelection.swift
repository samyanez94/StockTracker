//
//  StockPriceSelection.swift
//  StockTracker
//
//  Created by Samuel Yanez on 10/16/26.
//

import Foundation

/// Snaps a chart selection to a recorded price, including at the plot boundaries.
nonisolated enum StockPriceSelection {
    static func nearest(to date: Date, in points: [StockPricePoint]) -> StockPricePoint? {
        points.min {
            let left = abs($0.date.timeIntervalSince(date))
            let right = abs($1.date.timeIntervalSince(date))
            return left == right ? $0.date < $1.date : left < right
        }
    }
}
