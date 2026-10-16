//
//  TwelveDataTimeSeriesRequest.swift
//  StockTracker
//
//  Created by Samuel Yanez on 10/16/26.
//

import Foundation

/// Loads the latest 78 regular-session five-minute bars for one stock.
/// Live results can span sessions; this request does not promise a calendar-day range.
struct TwelveDataTimeSeriesRequest: StockRequest {
    let symbol: String

    func url(apiKey: String) throws -> URL {
        try TwelveDataAPI.url(
            path: "/time_series",
            queryItems: [
                URLQueryItem(name: "symbol", value: symbol),
                URLQueryItem(name: "interval", value: "5min"),
                URLQueryItem(name: "outputsize", value: "78"),
                URLQueryItem(name: "timezone", value: "Exchange"),
                URLQueryItem(name: "order", value: "asc"),
                URLQueryItem(name: "prepost", value: "false"),
            ],
            apiKey: apiKey
        )
    }

    func decode(_ data: Data) throws -> [StockPricePoint] {
        try TwelveDataAPI.decode(TwelveDataTimeSeriesResponse.self, from: data).points(for: symbol)
    }

    func mockData() throws -> Data? {
        let quote = try TwelveDataMockData.quote(for: symbol)
        guard let close = quote["close"] as? String,
              let price = Double(close)
        else {
            throw StockServiceError.invalidResponse
        }
        // Fixed synthetic session, independent of the device's clock and timezone.
        let values = (0 ..< 78).reversed().map { index -> [String: String] in
            let minute = 9 * 60 + 30 + index * 5
            let progress = Double(index) / 77
            let value = price * (0.99 + 0.01 * progress + 0.004 * sin(progress * 4 * .pi))
            let close = index == 77 ? price : (value * 100).rounded() / 100
            return [
                "datetime": String(format: "2026-10-15 %02d:%02d:00", minute / 60, minute % 60),
                "open": String(close), "high": String(close + 0.10),
                "low": String(close - 0.10), "close": String(close),
                "volume": String(100_000 + index * 1000),
            ]
        }
        return try JSONSerialization.data(
            withJSONObject: [
                "meta": [
                    "symbol": symbol,
                    "interval": "5min",
                    "currency": "USD",
                    "exchange_timezone": "America/New_York",
                    "type": "Common Stock",
                ],
                "values": values,
                "status": "ok",
            ]
        )
    }
}
