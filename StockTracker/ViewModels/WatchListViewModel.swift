//
//  WatchListViewModel.swift
//  StockTracker
//
//  Created by Samuel Yanez on 4/27/26.
//

import Foundation

@MainActor
@Observable
final class WatchListViewModel {
    var stocks: [Stock]

    var searchResults: [Stock] = []

    var quotes: [String: Quote] = [:]

    var searchText = ""

    var isSearchPresented = false

    var sortOption: WatchListSortOption = .symbol {
        didSet {
            watchlistStore.saveSortOption(sortOption)
        }
    }

    var sortDirection: WatchListSortDirection = .ascending {
        didSet {
            watchlistStore.saveSortDirection(sortDirection)
        }
    }

    private var symbols: [String] {
        stocks.map(\.symbol)
    }

    private let searchController: StockSearchController

    private let quoteRefreshController: QuoteRefreshController

    private let watchListSorter: WatchListSorter

    private let watchlistStore: any WatchlistStoring

    init(
        stocks: [Stock],
        service: any StockServicing,
        watchlistStore: any WatchlistStoring,
        searchDebounceDuration: Duration = .milliseconds(300),
        searchController: StockSearchController? = nil,
        quoteRefreshController: QuoteRefreshController? = nil,
        watchListSorter: WatchListSorter = WatchListSorter(),
    ) {
        self.stocks = stocks
        self.searchController = searchController ?? StockSearchController(
            service: service,
            debounceDuration: searchDebounceDuration,
        )
        self.quoteRefreshController = quoteRefreshController ?? QuoteRefreshController(
            service: service,
        )
        self.watchListSorter = watchListSorter
        self.watchlistStore = watchlistStore
        sortOption = watchlistStore.loadSortOption() ?? .symbol
        sortDirection = watchlistStore.loadSortDirection() ?? .ascending
    }

    func quote(for stock: Stock) -> Quote? {
        quotes[stock.symbol]
    }

    var sortedStocks: [Stock] {
        watchListSorter.sortedStocks(
            stocks,
            quotes: quotes,
            sortOption: sortOption,
            sortDirection: sortDirection,
        )
    }

    func isInWatchlist(_ stock: Stock) -> Bool {
        stocks.contains { $0.symbol == stock.symbol }
    }

    func toggleWatchlistMembership(for stock: Stock) async {
        if isInWatchlist(stock) {
            removeFromWatchlist(stock)
        } else {
            await addToWatchlist(stock)
        }
    }

    func addToWatchlist(_ stock: Stock) async {
        guard !isInWatchlist(stock) else {
            return
        }
        stocks.append(stock)
        saveWatchlist()
        await refresh()
    }

    func removeFromWatchlist(_ stock: Stock) {
        stocks.removeAll { $0.symbol == stock.symbol }
        quotes[stock.symbol] = nil
        saveWatchlist()
    }

    func search() async {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            searchController.cancel()
            searchResults = []
            return
        }
        let searchResults = await searchController.search(query: query)
        if query == searchText.trimmingCharacters(in: .whitespacesAndNewlines) {
            self.searchResults = searchResults
        }
    }

    func clearSearch() {
        searchController.cancel()
        searchText = ""
        searchResults = []
    }

    func refresh() async {
        if let quotes = await quoteRefreshController.refresh(symbols: symbols) {
            self.quotes = quotes
        }
    }

    func startPolling() async {
        await quoteRefreshController.startPolling(
            symbols: { self.symbols },
            update: { self.quotes = $0 },
        )
    }

    private func saveWatchlist() {
        watchlistStore.saveStocks(stocks)
    }
}
