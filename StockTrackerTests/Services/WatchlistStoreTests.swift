//
//  WatchlistStoreTests.swift
//  StockTrackerTests
//
//  Created by Samuel Yanez on 4/28/26.
//

@testable import StockTracker
import Foundation
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

    private func makeDefaults() -> UserDefaults {
        let suiteName = "StockTrackerTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }
}
