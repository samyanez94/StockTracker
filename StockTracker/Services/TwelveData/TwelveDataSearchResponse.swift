//
//  TwelveDataSearchResponse.swift
//  StockTracker
//
//  Created by Samuel Yanez on 10/14/26.
//

import Foundation

nonisolated struct TwelveDataSearchResponse: Decodable {

    let data: [TwelveDataSearchResult]

    var stocks: [Stock] {
        // Stock identity and price formatting currently support US symbols in USD.
        var seen: Set<String> = []
        return data.filter {
            $0.country == "United States" &&
            $0.currency == "USD" &&
            $0.instrumentType == "Common Stock" &&
            seen.insert($0.symbol).inserted
        }
        .map {
            Stock(symbol: $0.symbol, companyName: $0.instrumentName)
        }
    }
}
