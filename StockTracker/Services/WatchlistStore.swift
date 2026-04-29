//
//  WatchlistStore.swift
//  StockTracker
//
//  Created by Samuel Yanez on 4/28/26.
//

import Foundation

@MainActor
protocol WatchlistStoring {
    func loadStocks() -> [Stock]?
    func saveStocks(_ stocks: [Stock])
}

struct WatchlistStore: WatchlistStoring {
    private let defaults: UserDefaults
    
    private let key: String

    init(
        defaults: UserDefaults = .standard,
        key: String = "watchlist",
    ) {
        self.defaults = defaults
        self.key = key
    }

    func loadStocks() -> [Stock]? {
        guard let data = defaults.data(forKey: key) else {
            return nil
        }
        return try? JSONDecoder().decode([Stock].self, from: data)
    }

    func saveStocks(_ stocks: [Stock]) {
        guard let data = try? JSONEncoder().encode(stocks) else {
            return
        }
        defaults.set(data, forKey: key)
    }
}
