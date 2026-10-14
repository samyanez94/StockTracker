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

    enum CodingKeys: String, CodingKey {
        case symbol
        case close
        case percentChange = "percent_change"
    }

    func toQuote() throws -> Quote {
        guard let price = Double(close),
              price.isFinite,
              let change = Double(percentChange),
              change.isFinite
        else {
            throw StockServiceError.invalidResponse
        }
        return Quote(symbol: symbol, price: price, percentChange: change)
    }
}
