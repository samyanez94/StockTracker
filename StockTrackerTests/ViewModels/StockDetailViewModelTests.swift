//
//  StockDetailViewModelTests.swift
//  StockTrackerTests
//
//  Created by Samuel Yanez on 10/16/26.
//

import Foundation
@testable import StockTracker
import Testing

@MainActor
struct StockDetailViewModelTests {
    @Test
    func `loads history and preserves empty results`() async {
        for points in [[], [StockPricePoint(date: .now, price: 100)]] {
            let model = StockDetailViewModel(service: MockStockService(points: points))
            await model.load(symbol: "AAPL")
            guard case let .loaded(result) = model.state else {
                Issue.record("Expected loaded history")
                return
            }
            #expect(result == points)
        }
    }

    @Test
    func `errors show unavailable state`() async {
        let model = StockDetailViewModel(service: MockStockService(error: StockServiceError.invalidResponse))
        await model.load(symbol: "AAPL")
        guard case .failed = model.state else {
            Issue.record("Expected failed state")
            return
        }
    }

    @Test
    func `cancellation does not become a failure`() async {
        let model = StockDetailViewModel(service: MockStockService(error: CancellationError()))
        await model.load(symbol: "AAPL")
        guard case .loading = model.state else {
            Issue.record("Cancellation must not show a failure")
            return
        }
    }

    @Test
    func `cancelled task ignores returned results`() async {
        let model = StockDetailViewModel(service: MockStockService(points: [StockPricePoint(date: .now, price: 100)]))
        let task = Task { await model.load(symbol: "AAPL") }
        task.cancel()
        await task.value
        guard case .loading = model.state else {
            Issue.record("Cancelled result must not be displayed")
            return
        }
    }

    @Test(arguments: [
        ("America/New_York", "2026-10-15T19:55:00Z", "2026-10-16T13:30:00Z", "2026-10-16T13:35:00Z"),
        ("America/New_York", "2026-03-06T20:55:00Z", "2026-03-09T13:30:00Z", "2026-03-09T13:35:00Z"),
        ("Australia/Sydney", "2026-10-14T23:30:00Z", "2026-10-15T23:30:00Z", "2026-10-16T01:00:00Z"),
        ("America/New_York", "2026-10-16T00:30:00Z", "2026-10-16T13:30:00Z", "2026-10-16T13:35:00Z"),
    ])
    func `keeps only newest exchange local date`(zone: String, previous: String, first: String, last: String) async throws {
        let timeZone = try #require(TimeZone(identifier: zone))
        let formatter = ISO8601DateFormatter()
        let points = try [previous, first, last].enumerated().map { index, timestamp in
            try StockPricePoint(
                date: #require(formatter.date(from: timestamp)),
                price: 100 + Double(index),
                timeZone: timeZone
            )
        }
        // Unsorted input also verifies that the newest date determines the session.
        let service = MockStockService(points: [points[2], points[0], points[1]])
        let model = StockDetailViewModel(service: service)
        await model.load(symbol: "AAPL")
        guard case let .loaded(result) = model.state else {
            Issue.record("Expected latest session")
            return
        }
        #expect(result == Array(points.suffix(2)))
        #expect(await service.fetchCount == 1)
    }
}
