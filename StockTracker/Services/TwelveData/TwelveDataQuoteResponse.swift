//
//  TwelveDataQuoteResponse.swift
//  StockTracker
//
//  Created by Samuel Yanez on 10/14/26.
//

import Foundation

struct TwelveDataQuoteResponse: Decodable {
    let symbol: String
    let close: String
    let percentChange: String
    let currency: String?
    let change: String?
    let open: String?
    let previousClose: String?
    let volume: String?
    let averageVolume: String?
    let low: String?
    let high: String?
    let fiftyTwoWeek: PriceRange?

    struct PriceRange: Decodable {
        let low: String?
        let high: String?
    }

    enum CodingKeys: String, CodingKey {
        case symbol, close, currency, change, open, volume, low, high
        case percentChange = "percent_change"
        case previousClose = "previous_close"
        case averageVolume = "average_volume"
        case fiftyTwoWeek = "fifty_two_week"
    }

    func toQuote() throws -> Quote {
        guard let price = finiteNumber(close),
              let percentChange = finiteNumber(percentChange)
        else {
            throw StockServiceError.invalidResponse
        }
        return Quote(
            symbol: symbol,
            price: price,
            percentChange: percentChange,
            currency: currency.flatMap { $0.isEmpty ? nil : $0 } ?? "USD",
            change: finiteNumber(change),
            open: finiteNumber(open),
            previousClose: finiteNumber(previousClose),
            volume: shareCount(volume),
            averageVolume: shareCount(averageVolume),
            low: finiteNumber(low),
            high: finiteNumber(high),
            fiftyTwoWeekLow: finiteNumber(fiftyTwoWeek?.low),
            fiftyTwoWeekHigh: finiteNumber(fiftyTwoWeek?.high)
        )
    }

    private func finiteNumber(_ value: String?) -> Double? {
        guard let value,
              let number = Double(value),
              number.isFinite else {
            return nil
        }
        return number
    }

    private func shareCount(_ value: String?) -> Int64? {
        guard let value,
              let number = Int64(value),
              number >= 0 else {
            return nil
        }
        return number
    }
}
