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
    let stocks: [Stock]

    var quotes: [String: Quote] = [:]

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
