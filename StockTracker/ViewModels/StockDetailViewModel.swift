//
//  StockDetailViewModel.swift
//  StockTracker
//
//  Created by Samuel Yanez on 10/16/26.
//

import Foundation

/// Loads price history for a detail screen without polling or automatic retries.
@MainActor
@Observable
final class StockDetailViewModel {
    enum State {
        case loading
        case loaded([StockPricePoint])
        case failed
    }

    private(set) var state: State = .loading
    private let service: any StockServicing
    private var requestID = UUID()

    init(service: any StockServicing) {
        self.service = service
    }

    /// Loads history, ignoring cancelled or superseded results.
    func load(symbol: String) async {
        let id = UUID()
        requestID = id
        state = .loading
        do {
            let points = try await service.fetchTimeSeries(symbol: symbol)
            try Task.checkCancellation()
            guard requestID == id else { return }
            state = .loaded(points)
        } catch {
            guard requestID == id, !Task.isCancelled, !(error is CancellationError) else { return }
            state = .failed
        }
    }
}
