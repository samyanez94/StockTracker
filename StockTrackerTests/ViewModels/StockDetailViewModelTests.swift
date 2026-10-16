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
}
