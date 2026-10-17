//
//  TwelveDataTimeSeriesRequest.swift
//  StockTracker
//
//  Created by Samuel Yanez on 10/16/26.
//

import Foundation

/// Loads range-appropriate regular-session bars; the view model trims calendar boundaries.
struct TwelveDataTimeSeriesRequest: StockRequest {
    let symbol: String
    var range: StockChartRange = .day

    func url(apiKey: String) throws -> URL {
        try TwelveDataAPI.url(
            path: "/time_series",
            queryItems: [
                URLQueryItem(name: "symbol", value: symbol),
                URLQueryItem(name: "interval", value: range.interval),
                URLQueryItem(name: "outputsize", value: String(range.outputSize)),
                URLQueryItem(name: "timezone", value: "Exchange"),
                URLQueryItem(name: "order", value: "asc"),
                URLQueryItem(name: "prepost", value: "false"),
            ],
            apiKey: apiKey
        )
    }

    func decode(_ data: Data) throws -> [StockPricePoint] {
        try TwelveDataAPI.decode(
            TwelveDataTimeSeriesResponse.self, from: data
        )
        .points(for: symbol, range: range)
    }

    func mockData() throws -> Data? {
        let quote = try TwelveDataMockData.quote(for: symbol)
        guard let close = quote["close"] as? String,
              let price = Double(close)
        else {
            throw StockServiceError.invalidResponse
        }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/New_York")!
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = range.isIntraday ? "yyyy-MM-dd HH:mm:ss" : "yyyy-MM-dd"
        let anchor = calendar.date(from: DateComponents(year: 2026, month: 10, day: range == .year ? 12 : 15))!
        var dates: [Date] = []
        var day = anchor
        while dates.count < range.outputSize {
            if !calendar.isDateInWeekend(day) {
                if range.isIntraday {
                    let minutes = range == .day ? 5 : 30
                    for minute in stride(from: 9 * 60 + 30, to: 16 * 60, by: minutes).reversed() {
                        if dates.count < range.outputSize {
                            dates.append(calendar.date(byAdding: .minute, value: minute, to: day)!)
                        }
                    }
                } else {
                    dates.append(day)
                }
            }
            day = calendar.date(byAdding: .day, value: range == .year ? -7 : -1, to: day)!
        }
        let values = dates.sorted().enumerated().map { index, date -> [String: String] in
            let progress = Double(index) / Double(range.outputSize - 1)
            let amplitude = range == .day ? 0.01 : 0.12
            let value = price * (1 - amplitude + amplitude * progress + amplitude * 0.4 * sin(progress * 4 * .pi))
            let close = index == range.outputSize - 1 ? price : (value * 100).rounded() / 100
            return [
                "datetime": formatter.string(from: date),
                "open": String(close), "high": String(close + 0.10),
                "low": String(close - 0.10), "close": String(close),
                "volume": String(100_000 + index * 1000),
            ]
        }.reversed()
        return try JSONSerialization.data(
            withJSONObject: [
                "meta": [
                    "symbol": symbol,
                    "interval": range.interval,
                    "currency": "USD",
                    "exchange_timezone": "America/New_York",
                    "type": "Common Stock",
                ],
                "values": Array(values),
                "status": "ok",
            ]
        )
    }
}
