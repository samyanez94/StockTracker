//
//  StockListViewModel.swift
//  StockTracker
//
//  Created by Samuel Yanez on 4/27/26.
//

import Foundation

@MainActor
@Observable
final class StockListViewModel {
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

    init(
        stocks: [Stock],
        service: any StockServicing,
    ) {
        self.stocks = stocks
        self.service = service
    }

    func quote(for stock: Stock) -> Quote? {
        quotes[stock.symbol]
    }

    func search() async {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        do {
            let searchResults = try await service.fetch(
                StockDataSearchRequest(query: query),
            )
            if query == searchText.trimmingCharacters(in: .whitespacesAndNewlines) {
                self.searchResults = searchResults
            }
        } catch {
            searchResults = []
        }
    }

    func clearSearch() {
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
                StockDataQuotesRequest(symbols: symbols),
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
}
