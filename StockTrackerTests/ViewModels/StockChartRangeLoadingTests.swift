//
//  StockChartRangeLoadingTests.swift
//  StockTrackerTests
//
//  Created by Samuel Yanez on 10/17/26.
//

import Foundation
@testable import StockTracker
import Testing

@MainActor
struct StockChartRangeLoadingTests {
    @Test
    func `cache is keyed by stock and range`() async {
        let service = MockStockService(points: [StockPricePoint(date: .now, price: 100)])
        let model = StockDetailViewModel(service: service)
        await model.load(symbol: "AAPL", range: .day)
        await model.load(symbol: "AAPL", range: .week)
        await model.load(symbol: "AAPL", range: .day)
        #expect(await service.fetchCount == 2)
        await model.load(symbol: "MSFT", range: .day)
        #expect(await service.fetchCount == 3)
    }

    @Test
    func `late responses cannot overwrite a newer range`() async {
        let service = ControlledHistoryService()
        let model = StockDetailViewModel(service: service)
        let day = Task { await model.load(symbol: "AAPL", range: .day) }
        await service.waitForRequest(.day)
        model.selectedRange = .week
        let week = Task { await model.load(symbol: "AAPL", range: .week) }
        await service.waitForRequest(.week)
        let newest = StockPricePoint(date: .now, price: 200)
        await service.finish(.week, points: [newest])
        await week.value
        await service.finish(.day, points: [StockPricePoint(date: .now, price: 100)])
        await day.value
        guard case let .loaded(points) = model.state else {
            Issue.record("Expected the newer range to remain loaded")
            return
        }
        #expect(points == [newest])
    }
}

private actor ControlledHistoryService: StockServicing {
    private var pending: [StockChartRange: CheckedContinuation<[StockPricePoint], Never>] = [:]
    private var waiters: [StockChartRange: CheckedContinuation<Void, Never>] = [:]

    func fetchQuotes(symbols _: [String]) async throws -> [Quote] {
        []
    }

    func searchStocks(query _: String) async throws -> [Stock] {
        []
    }

    func fetchTimeSeries(symbol _: String, range: StockChartRange) async throws -> [StockPricePoint] {
        await withCheckedContinuation { continuation in
            pending[range] = continuation
            waiters.removeValue(forKey: range)?.resume()
        }
    }

    func waitForRequest(_ range: StockChartRange) async {
        if pending[range] != nil {
            return
        }
        await withCheckedContinuation { waiters[range] = $0 }
    }

    func finish(_ range: StockChartRange, points: [StockPricePoint]) {
        pending.removeValue(forKey: range)?.resume(returning: points)
    }
}
