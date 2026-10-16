//
//  TwelveDataTimeSeriesRequestTests.swift
//  StockTrackerTests
//
//  Created by Samuel Yanez on 10/16/26.
//

import Foundation
@testable import StockTracker
import Testing

@MainActor
struct TwelveDataTimeSeriesRequestTests {
    @Test
    func `request uses time series endpoint`() throws {
        let url = try TwelveDataTimeSeriesRequest(symbol: "AAPL").url(apiKey: "test-key")
        let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
        #expect(components.host == "api.twelvedata.com")
        #expect(components.path == "/time_series")
        let items = components.queryItems ?? []
        for (name, value) in ["symbol": "AAPL", "interval": "5min", "outputsize": "78", "timezone": "Exchange", "order": "asc", "prepost": "false", "apikey": "test-key"] {
            #expect(items.contains(URLQueryItem(name: name, value: value)))
        }
    }

    @Test(arguments: ["2026-01-15", "2026-07-15"])
    func `exchange timezone respects daylight saving`(day: String) throws {
        let points = try decode(values: [
            ["datetime": "\(day) 09:35:00", "close": "102.50"],
            ["datetime": "\(day) 09:30:00", "close": "101.25"],
        ])
        let first = try #require(points.first)
        let expected = try #require(ISO8601DateFormatter().date(from: "\(day)T\(day.contains("01-15") ? "14" : "13"):30:00Z"))
        #expect(first.date == expected)
        #expect(first.price == 101.25)
        #expect(points[1].date.timeIntervalSince(first.date) == 300)
    }

    @Test(arguments: ["NaN", "Infinity", "oops", "-1", "0"])
    func `invalid prices fail`(price: String) {
        #expect(throws: StockServiceError.invalidResponse) {
            try decode(values: [["datetime": "2026-10-15 09:30:00", "close": price]])
        }
    }

    @Test
    func `invalid metadata timestamps and duplicates fail`() {
        let bar = ["datetime": "2026-10-15 09:30:00", "close": "100"]
        for (symbol, zone) in [("MSFT", "America/New_York"), ("AAPL", "Invalid/Zone")] {
            #expect(throws: StockServiceError.invalidResponse) {
                try decode(values: [bar], symbol: symbol, zone: zone)
            }
        }
        #expect(throws: StockServiceError.invalidResponse) { try decode(values: [bar, bar]) }
        #expect(throws: StockServiceError.invalidResponse) {
            try decode(values: [["datetime": "not-a-date", "close": "100"]])
        }
    }

    @Test
    func `empty results and API errors are preserved`() throws {
        #expect(try decode(values: []).isEmpty)
        let data = Data(#"{"status":"error","code":429,"message":"Limit reached"}"#.utf8)
        #expect(throws: StockServiceError.apiError(code: 429, message: "Limit reached")) {
            try TwelveDataTimeSeriesRequest(symbol: "AAPL").decode(data)
        }
    }

    @Test
    func `mock service supplies every supported stock without a key`() async throws {
        let service: any StockServicing = StockService(usesMockData: true, apiKey: "")
        for stock in TwelveDataMockData.stocks {
            let points = try await service.fetchTimeSeries(symbol: stock.symbol)
            let repeated = try await service.fetchTimeSeries(symbol: stock.symbol)
            let quote = try #require(try await service.fetchQuotes(symbols: [stock.symbol]).first)
            #expect(points.count == 78)
            #expect(points == repeated)
            #expect(points.last?.price == quote.price)
            #expect(Set(points.map(\.id)).count == 78)
            for (previous, next) in zip(points, points.dropFirst()) {
                #expect(next.date.timeIntervalSince(previous.date) == 300)
            }
        }
        await #expect(throws: StockServiceError.missingMockData) {
            try await service.fetchTimeSeries(symbol: "UNKNOWN")
        }
        await #expect(throws: StockServiceError.missingAPIKey) {
            try await StockService(usesMockData: false, apiKey: "").fetchTimeSeries(symbol: "AAPL")
        }
    }

    private func decode(values: [[String: String]], symbol: String = "AAPL", zone: String = "America/New_York") throws -> [StockPricePoint] {
        let data = try JSONSerialization.data(withJSONObject: [
            "meta": ["symbol": symbol, "interval": "5min", "exchange_timezone": zone],
            "values": values, "status": "ok",
        ])
        return try TwelveDataTimeSeriesRequest(symbol: "AAPL").decode(data)
    }
}
