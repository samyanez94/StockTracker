//
//  QuoteRefreshController.swift
//  StockTracker
//
//  Created by Samuel Yanez on 4/28/26.
//

import Foundation

@MainActor
final class QuoteRefreshController {
    private var isRefreshing = false

    private let service: any StockServicing

    init(service: any StockServicing) {
        self.service = service
    }

    func refresh(symbols: [String]) async -> [String: Quote]? {
        guard !isRefreshing else {
            return nil
        }
        isRefreshing = true
        defer {
            isRefreshing = false
        }

        do {
            let fetchedQuotes = try await service.fetch(
                StockDataQuoteRequest(symbols: symbols),
            )
            return Dictionary(
                uniqueKeysWithValues: fetchedQuotes.map { ($0.symbol, $0) },
            )
        } catch {
            return nil
        }
    }

    func startPolling(
        symbols: @escaping () -> [String],
        update: @escaping ([String: Quote]) -> Void,
    ) async {
        while !Task.isCancelled {
            if let quotes = await refresh(symbols: symbols()) {
                update(quotes)
            }
            try? await Task.sleep(for: .seconds(60))
        }
    }
}
