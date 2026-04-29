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

    private var symbols: [String] {
        stocks.map(\.symbol)
    }

    private var isRefreshing = false

    private let service: any StockServicing

    private let searchController: StockSearchController

    private let watchlistStore: any WatchlistStoring

    init(
        stocks: [Stock],
        service: any StockServicing,
        watchlistStore: any WatchlistStoring,
        searchDebounceDuration: Duration = .milliseconds(300),
        searchController: StockSearchController? = nil,
    ) {
        self.stocks = stocks
        self.service = service
        self.searchController = searchController ?? StockSearchController(
            service: service,
            debounceDuration: searchDebounceDuration,
        )
        self.watchlistStore = watchlistStore
    }

    func quote(for stock: Stock) -> Quote? {
        quotes[stock.symbol]
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
        guard !isRefreshing else {
            return
        }
        isRefreshing = true
        defer {
            isRefreshing = false
        }
        do {
            let fetchedQuotes = try await service.fetch(
                StockDataQuoteRequest(symbols: symbols),
            )
            updateQuotes(with: fetchedQuotes)
        } catch {
            return
        }
    }

    func startPolling() async {
        while !Task.isCancelled {
            await refresh()
            try? await Task.sleep(for: .seconds(60))
        }
    }

    private func updateQuotes(with fetchedQuotes: [Quote]) {
        quotes = Dictionary(
            uniqueKeysWithValues: fetchedQuotes.map { ($0.symbol, $0) },
        )
    }

    private func saveWatchlist() {
        watchlistStore.saveStocks(stocks)
    }
}
