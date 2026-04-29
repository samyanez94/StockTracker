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
    func loadSortOption() -> WatchListSortOption?
    func saveSortOption(_ sortOption: WatchListSortOption)
    func loadSortDirection() -> WatchListSortDirection?
    func saveSortDirection(_ sortDirection: WatchListSortDirection)
}

struct WatchlistStore: WatchlistStoring {
    private let defaults: UserDefaults

    private let key: String

    private let sortOptionKey: String

    private let sortDirectionKey: String

    init(
        defaults: UserDefaults = .standard,
        key: String = "watchlist",
        sortOptionKey: String = "watchlistSortOption",
        sortDirectionKey: String = "watchlistSortDirection",
    ) {
        self.defaults = defaults
        self.key = key
        self.sortOptionKey = sortOptionKey
        self.sortDirectionKey = sortDirectionKey
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

    func loadSortOption() -> WatchListSortOption? {
        guard let rawValue = defaults.string(forKey: sortOptionKey) else {
            return nil
        }
        return WatchListSortOption(rawValue: rawValue)
    }

    func saveSortOption(_ sortOption: WatchListSortOption) {
        defaults.set(sortOption.rawValue, forKey: sortOptionKey)
    }

    func loadSortDirection() -> WatchListSortDirection? {
        guard let rawValue = defaults.string(forKey: sortDirectionKey) else {
            return nil
        }
        return WatchListSortDirection(rawValue: rawValue)
    }

    func saveSortDirection(_ sortDirection: WatchListSortDirection) {
        defaults.set(sortDirection.rawValue, forKey: sortDirectionKey)
    }
}
