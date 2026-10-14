//
//  QuoteRefreshController.swift
//  StockTracker
//
//  Created by Samuel Yanez on 4/28/26.
//

import Foundation

/// Fetches quote snapshots while preventing overlapping nonempty refresh requests.
///
/// Supports one-off refreshes and polling that runs until its calling task is cancelled.
@MainActor
final class QuoteRefreshController {

    private var isRefreshing = false

    private let service: any StockServicing

    /// Creates a controller with the service used to load quotes.
    /// - Parameter service: The live or mock stock-data service.
    init(service: any StockServicing) {
        self.service = service
    }

    /// Fetches quotes indexed by their stock symbols.
    /// - Parameter symbols: Unique stock symbols to refresh.
    /// - Returns: An empty dictionary for an empty symbol list, the fetched quotes on
    ///   success, or `nil` if a refresh is already running or the request fails.
    ///   Callers can retain their existing quotes when the result is `nil`.
    func refresh(symbols: [String]) async -> [String: Quote]? {
        guard !symbols.isEmpty else {
            return [:]
        }
        guard !isRefreshing else {
            return nil
        }
        isRefreshing = true
        defer {
            isRefreshing = false
        }

        do {
            let fetchedQuotes = try await service.fetchQuotes(symbols: symbols)
            return Dictionary(
                uniqueKeysWithValues: fetchedQuotes.map { ($0.symbol, $0) },
            )
        } catch {
            return nil
        }
    }

    /// Refreshes immediately, then waits 60 seconds after each attempt before repeating.
    ///
    /// Runs until the calling task is cancelled. The symbol list is read on each iteration.
    /// - Parameters:
    ///   - symbols: Supplies the current watchlist symbols.
    ///   - update: Receives successful snapshots, including an empty snapshot for an empty
    ///     watchlist. Failed or overlapping refreshes do not invoke this closure.
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
