//
//  TwelveDataSearchRequest.swift
//  StockTracker
//
//  Created by Samuel Yanez on 10/14/26.
//

import Foundation

nonisolated struct TwelveDataSearchRequest: StockRequest {
    let query: String

    func url(apiKey: String) throws -> URL {
        try TwelveDataAPI.url(
            path: "/symbol_search",
            queryItems: [URLQueryItem(name: "symbol", value: query)],
            apiKey: apiKey
        )
    }

    func decode(_ data: Data) throws -> [Stock] {
        try TwelveDataAPI.decode(TwelveDataSearchResponse.self, from: data).stocks
    }

    func mockData() throws -> Data? {
        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let results = TwelveDataMockData.stocks.filter {
            !query.isEmpty && ($0.symbol.localizedCaseInsensitiveContains(query)
                || $0.companyName.localizedCaseInsensitiveContains(query))
        }
        .map {
            [
                "symbol": $0.symbol,
                "instrument_name": $0.companyName,
                "exchange": "NASDAQ",
                "mic_code": "XNAS",
                "exchange_timezone": "America/New_York",
                "instrument_type": "Common Stock",
                "country": "United States",
                "currency": "USD",
            ]
        }
        return try JSONSerialization.data(
            withJSONObject: ["data": results, "status": "ok"]
        )
    }
}
