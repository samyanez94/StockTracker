//
//  StockSearchController.swift
//  StockTracker
//
//  Created by Samuel Yanez on 4/28/26.
//

import Foundation

@MainActor
final class StockSearchController {
    private var searchTask: Task<[Stock], Never>?

    private let service: any StockServicing

    private let debounceDuration: Duration

    init(
        service: any StockServicing,
        debounceDuration: Duration = .milliseconds(300),
    ) {
        self.service = service
        self.debounceDuration = debounceDuration
    }

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
                return try await service.fetch(
                    StockDataSearchRequest(query: query),
                )
            } catch is CancellationError {
                return []
            } catch {
                return []
            }
        }
        searchTask = task
        return await task.value
    }

    func cancel() {
        searchTask?.cancel()
        searchTask = nil
    }
}
