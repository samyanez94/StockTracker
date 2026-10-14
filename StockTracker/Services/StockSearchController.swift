//
//  StockSearchController.swift
//  StockTracker
//
//  Created by Samuel Yanez on 4/28/26.
//

import Foundation

/// Debounces stock searches and manages cancellation of the previous search task.
///
/// Search failures are represented as empty results rather than thrown errors.
@MainActor
final class StockSearchController {
    private var searchTask: Task<[Stock], Never>?

    private let service: any StockServicing

    private let debounceDuration: Duration

    /// Creates a controller using the supplied service and debounce interval.
    /// - Parameters:
    ///   - service: The service used to fetch matching stocks.
    ///   - debounceDuration: How long to wait before fetching, defaulting to 300 milliseconds.
    init(
        service: any StockServicing,
        debounceDuration: Duration = .milliseconds(300)
    ) {
        self.service = service
        self.debounceDuration = debounceDuration
    }

    /// Cancels the previous search and fetches matches after the debounce interval.
    /// - Parameter query: The search text. Callers are responsible for trimming whitespace.
    /// - Returns: Matching stocks, or an empty array for an empty query or a thrown error,
    ///   including cancellation. Callers should verify the query is still current before
    ///   displaying results, since cancellation is cooperative.
    func search(query: String) async -> [Stock] {
        searchTask?.cancel()

        guard !query.isEmpty else {
            return []
        }

        let debounceDuration = debounceDuration
        let service = service
        let task = Task {
            do {
                try await Task.sleep(for: debounceDuration)
                try Task.checkCancellation()
                return try await service.searchStocks(query: query)
            } catch is CancellationError {
                return []
            } catch {
                return []
            }
        }
        searchTask = task
        return await task.value
    }

    /// Requests cancellation of the current search task and releases its handle.
    func cancel() {
        searchTask?.cancel()
        searchTask = nil
    }
}
