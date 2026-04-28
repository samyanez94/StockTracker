//
//  StockListViewModelTests.swift
//  StockTrackerTests
//
//  Created by Samuel Yanez on 4/28/26.
//

import Foundation
@testable import StockTracker
import Testing

@MainActor
struct StockListViewModelTests {
    @Test
    func `refresh stores fetched quotes`() async {
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

    @Test
    func `search stores matching results separately from stocks`() async {
        let apple = Stock(symbol: "AAPL", companyName: "Apple Inc.")
        let microsoft = Stock(symbol: "MSFT", companyName: "Microsoft Corporation")
        let service = MockStockService(searchResults: [apple, microsoft])
        let viewModel = StockListViewModel(stocks: [apple], service: service)

        viewModel.searchText = "micro"
        await viewModel.search()

        #expect(viewModel.stocks == [apple])
        #expect(viewModel.searchResults == [microsoft])
    }

    @Test
    func `clearing search removes search results and preserves stocks`() {
        let apple = Stock(symbol: "AAPL", companyName: "Apple Inc.")
        let microsoft = Stock(symbol: "MSFT", companyName: "Microsoft Corporation")
        let viewModel = StockListViewModel(stocks: [apple], service: MockStockService())
        viewModel.searchText = "micro"
        viewModel.searchResults = [microsoft]

        viewModel.clearSearch()

        #expect(viewModel.searchText.isEmpty)
        #expect(viewModel.stocks == [apple])
        #expect(viewModel.searchResults.isEmpty)
    }
}

private actor MockStockService: StockServicing {
    let quotes: [Quote]
    let searchResults: [Stock]
    let error: Error?
    let delay: Duration
    private(set) var fetchCount = 0

    init(
        quotes: [Quote] = [],
        searchResults: [Stock] = [],
        error: Error? = nil,
        delay: Duration = .zero,
    ) {
        self.quotes = quotes
        self.searchResults = searchResults
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
        if let request = request as? StockDataSearchRequest,
           let response = searchResults.filter({
               $0.symbol.localizedCaseInsensitiveContains(request.query)
                   || $0.companyName.localizedCaseInsensitiveContains(request.query)
           }) as? Request.Response
        {
            return response
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
