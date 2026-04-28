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
    enum LoadState {
        case idle
        case loading
        case loaded
    }

    let stocks: [Stock]

    var quotes: [String: Quote] = [:]

    var isLoading: Bool {
        if case .loading = state {
            return true
        }
        return false
    }

    private var symbols: [String] {
        stocks.map(\.symbol)
    }

    private(set) var state = LoadState.idle

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
        guard !isLoading else {
            return
        }
        state = .loading
        do {
            let fetchedQuotes = try await service.fetch(
                StockDataQuotesRequest(symbols: symbols),
            )
            updateQuotes(with: fetchedQuotes)
            state = .loaded
        } catch is CancellationError {
            state = quotes.isEmpty ? .idle : .loaded
        } catch {
            state = quotes.isEmpty ? .idle : .loaded
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
