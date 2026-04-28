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
        case failed(String)
    }

    let stocks = [
        Stock(symbol: "AAPL", companyName: "Apple Inc."),
        Stock(symbol: "MSFT", companyName: "Microsoft"),
        Stock(symbol: "TSLA", companyName: "Tesla"),
    ]

    var quotes: [String: Quote] = [:]

    var isShowingErrorAlert = false

    var isLoading: Bool {
        if case .loading = loadState {
            return true
        }
        return false
    }

    var errorMessage: String? {
        if case let .failed(message) = loadState {
            return message
        }
        return nil
    }

    private var symbols: [String] {
        stocks.map(\.symbol)
    }

    private(set) var loadState = LoadState.idle

    private let service: any StockServicing

    init(service: any StockServicing = StockService(usesMockData: true)) {
        self.service = service
    }

    func quote(for stock: Stock) -> Quote? {
        quotes[stock.symbol]
    }

    func dismissError() {
        isShowingErrorAlert = false
        loadState = quotes.isEmpty ? .idle : .loaded
    }

    func refresh() async {
        guard !isLoading else {
            return
        }
        loadState = .loading
        do {
            let fetchedQuotes = try await service.fetch(
                StockDataQuotesRequest(symbols: symbols)
            )
            updateQuotes(with: fetchedQuotes)
            loadState = .loaded
        } catch is CancellationError {
            loadState = quotes.isEmpty ? .idle : .loaded
        } catch {
            loadState = .failed(error.localizedDescription)
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
            uniqueKeysWithValues: fetchedQuotes.map { ($0.symbol, $0) }
        )
    }
}
