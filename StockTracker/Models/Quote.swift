//
//  Quote.swift
//  StockTracker
//
//  Created by Samuel Yanez on 4/27/26.
//

import Foundation

struct Quote {
    let symbol: String
    let price: Double
    let percentChange: Double
    let currency: String
    let change: Double?
    let open: Double?
    let previousClose: Double?
    let volume: Int64?
    let averageVolume: Int64?
    let low: Double?
    let high: Double?
    let fiftyTwoWeekLow: Double?
    let fiftyTwoWeekHigh: Double?

    init(
        symbol: String,
        price: Double,
        percentChange: Double,
        currency: String = "USD",
        change: Double? = nil,
        open: Double? = nil,
        previousClose: Double? = nil,
        volume: Int64? = nil,
        averageVolume: Int64? = nil,
        low: Double? = nil,
        high: Double? = nil,
        fiftyTwoWeekLow: Double? = nil,
        fiftyTwoWeekHigh: Double? = nil
    ) {
        self.symbol = symbol
        self.price = price
        self.percentChange = percentChange
        self.currency = currency
        self.change = change
        self.open = open
        self.previousClose = previousClose
        self.volume = volume
        self.averageVolume = averageVolume
        self.low = low
        self.high = high
        self.fiftyTwoWeekLow = fiftyTwoWeekLow
        self.fiftyTwoWeekHigh = fiftyTwoWeekHigh
    }
}
