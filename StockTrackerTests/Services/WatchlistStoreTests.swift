//
//  WatchlistStoreTests.swift
//  StockTrackerTests
//
//  Created by Samuel Yanez on 4/28/26.
//

import Foundation
@testable import StockTracker
import Testing

@MainActor
struct WatchlistStoreTests {
    @Test
    func `load returns nil when no watchlist has been saved`() {
        let defaults = makeDefaults()
        let store = WatchlistStore(defaults: defaults)

        #expect(store.loadStocks() == nil)
    }

    @Test
    func `save and load stocks`() {
        let defaults = makeDefaults()
        let stock = Stock(symbol: "AAPL", companyName: "Apple Inc.")
        let store = WatchlistStore(defaults: defaults)

        store.saveStocks([stock])

        #expect(store.loadStocks() == [stock])
    }

    @Test
    func `empty saved watchlist loads as empty`() {
        let defaults = makeDefaults()
        let store = WatchlistStore(defaults: defaults)

        store.saveStocks([])

        #expect(store.loadStocks() == [])
    }

    @Test
    func `save and load sort option`() {
        let defaults = makeDefaults()
        let store = WatchlistStore(defaults: defaults)

        store.saveSortOption(.percentageChange)

        #expect(store.loadSortOption() == .percentageChange)
    }

    @Test
    func `save and load sort direction`() {
        let defaults = makeDefaults()
        let store = WatchlistStore(defaults: defaults)

        store.saveSortDirection(.descending)

        #expect(store.loadSortDirection() == .descending)
    }

    private func makeDefaults() -> UserDefaults {
        let suiteName = "StockTrackerTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }
}
