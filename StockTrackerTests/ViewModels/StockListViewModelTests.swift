//
//  StockListViewModelTests.swift
//  StockTrackerTests
//
//  Created by Samuel Yanez on 4/28/26.
//

@testable import StockTracker
import Foundation
import Testing

@MainActor
struct StockListViewModelTests {
    @Test
    func `refresh stores fetched quotes`() async throws {
        let stock = Stock(symbol: "AAPL", companyName: "Apple Inc.")
        let quote = Quote(symbol: "AAPL", price: 204.18, percentChange: 0.62)
        let viewModel = StockListViewModel(
            stocks: [stock],
            service: MockStockService(quotes: [quote]),
        )

        await viewModel.refresh()

        #expect(viewModel.quote(for: stock)?.symbol == "AAPL")
        #expect(viewModel.quote(for: stock)?.price == 204.18)
        #expect(viewModel.quote(for: stock)?.percentChange == 0.62)
    }

    @Test
    func `failed refresh preserves existing quotes`() async {
        let stock = Stock(symbol: "AAPL", companyName: "Apple Inc.")
        let quote = Quote(symbol: "AAPL", price: 204.18, percentChange: 0.62)
        let viewModel = StockListViewModel(
            stocks: [stock],
            service: MockStockService(error: TestError.fetchFailed),
        )
        viewModel.quotes = [quote.symbol: quote]

        await viewModel.refresh()

        #expect(viewModel.quote(for: stock)?.price == 204.18)
        #expect(viewModel.quote(for: stock)?.percentChange == 0.62)
    }

    @Test
    func `refresh ignores overlapping requests`() async {
        let stock = Stock(symbol: "AAPL", companyName: "Apple Inc.")
        let quote = Quote(symbol: "AAPL", price: 204.18, percentChange: 0.62)
        let service = MockStockService(quotes: [quote], delay: .milliseconds(100))
        let viewModel = StockListViewModel(stocks: [stock], service: service)

        let firstRefresh = Task {
            await viewModel.refresh()
        }
        await Task.yield()

        await viewModel.refresh()
        await firstRefresh.value

        let fetchCount = await service.fetchCount
        #expect(fetchCount == 1)
    }
}

private actor MockStockService: StockServicing {
    let quotes: [Quote]
    let error: Error?
    let delay: Duration
    private(set) var fetchCount = 0

    init(
        quotes: [Quote] = [],
        error: Error? = nil,
        delay: Duration = .zero,
    ) {
        self.quotes = quotes
        self.error = error
        self.delay = delay
    }

    func fetch<Request: StockRequest>(_ request: Request) async throws -> Request.Response {
        fetchCount += 1
        if delay > .zero {
            try await Task.sleep(for: delay)
        }
        if let error {
            throw error
        }
        guard let response = quotes as? Request.Response else {
            throw TestError.unexpectedResponseType
        }
        return response
    }
}

private enum TestError: Error {
    case fetchFailed
    case unexpectedResponseType
}
