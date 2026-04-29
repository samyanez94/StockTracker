//
//  WatchListSorterTests.swift
//  StockTrackerTests
//
//  Created by Samuel Yanez on 4/28/26.
//

@testable import StockTracker
import Testing

struct WatchListSorterTests {
    private let sorter = WatchListSorter()

    @Test
    func `sorts by symbol`() {
        let apple = Stock(symbol: "AAPL", companyName: "Apple Inc.")
        let tesla = Stock(symbol: "TSLA", companyName: "Tesla, Inc.")
        let microsoft = Stock(symbol: "MSFT", companyName: "Microsoft Corporation")

        let sortedStocks = sorter.sortedStocks(
            [tesla, microsoft, apple],
            quotes: [:],
            sortOption: .symbol,
            sortDirection: .ascending,
        )

        #expect(sortedStocks == [apple, microsoft, tesla])
    }

    @Test
    func `sorts by symbol descending`() {
        let apple = Stock(symbol: "AAPL", companyName: "Apple Inc.")
        let tesla = Stock(symbol: "TSLA", companyName: "Tesla, Inc.")
        let microsoft = Stock(symbol: "MSFT", companyName: "Microsoft Corporation")

        let sortedStocks = sorter.sortedStocks(
            [tesla, microsoft, apple],
            quotes: [:],
            sortOption: .symbol,
            sortDirection: .descending,
        )

        #expect(sortedStocks == [tesla, microsoft, apple])
    }

    @Test
    func `sorts by name`() {
        let apple = Stock(symbol: "AAPL", companyName: "Apple Inc.")
        let tesla = Stock(symbol: "TSLA", companyName: "Tesla, Inc.")
        let microsoft = Stock(symbol: "MSFT", companyName: "Microsoft Corporation")

        let sortedStocks = sorter.sortedStocks(
            [tesla, microsoft, apple],
            quotes: [:],
            sortOption: .name,
            sortDirection: .ascending,
        )

        #expect(sortedStocks == [apple, microsoft, tesla])
    }

    @Test
    func `sorts by name descending`() {
        let apple = Stock(symbol: "AAPL", companyName: "Apple Inc.")
        let tesla = Stock(symbol: "TSLA", companyName: "Tesla, Inc.")
        let microsoft = Stock(symbol: "MSFT", companyName: "Microsoft Corporation")

        let sortedStocks = sorter.sortedStocks(
            [tesla, microsoft, apple],
            quotes: [:],
            sortOption: .name,
            sortDirection: .descending,
        )

        #expect(sortedStocks == [tesla, microsoft, apple])
    }

    @Test
    func `sorts by percentage change with missing quotes last`() {
        let apple = Stock(symbol: "AAPL", companyName: "Apple Inc.")
        let tesla = Stock(symbol: "TSLA", companyName: "Tesla, Inc.")
        let microsoft = Stock(symbol: "MSFT", companyName: "Microsoft Corporation")
        let quotes = [
            "AAPL": Quote(symbol: "AAPL", price: 204.18, percentChange: -0.5),
            "MSFT": Quote(symbol: "MSFT", price: 391.44, percentChange: 0.34),
        ]

        let sortedStocks = sorter.sortedStocks(
            [apple, tesla, microsoft],
            quotes: quotes,
            sortOption: .percentageChange,
            sortDirection: .descending,
        )

        #expect(sortedStocks == [microsoft, apple, tesla])
    }

    @Test
    func `sorts by percentage change ascending with missing quotes last`() {
        let apple = Stock(symbol: "AAPL", companyName: "Apple Inc.")
        let tesla = Stock(symbol: "TSLA", companyName: "Tesla, Inc.")
        let microsoft = Stock(symbol: "MSFT", companyName: "Microsoft Corporation")
        let quotes = [
            "AAPL": Quote(symbol: "AAPL", price: 204.18, percentChange: -0.5),
            "MSFT": Quote(symbol: "MSFT", price: 391.44, percentChange: 0.34),
        ]

        let sortedStocks = sorter.sortedStocks(
            [apple, tesla, microsoft],
            quotes: quotes,
            sortOption: .percentageChange,
            sortDirection: .ascending,
        )

        #expect(sortedStocks == [apple, microsoft, tesla])
    }
}
