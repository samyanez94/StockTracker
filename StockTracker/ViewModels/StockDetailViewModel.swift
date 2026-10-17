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

    var selectedRange: StockChartRange = .day {
        didSet {
            guard selectedRange != oldValue else {
                return
            }
            requestID = UUID()
            state = .loading
        }
    }

    private var cache: [String: [StockChartRange: [StockPricePoint]]] = [:]

    private let service: any StockServicing

    private var requestID = UUID()

    init(service: any StockServicing) {
        self.service = service
    }

    /// Loads or reuses a range, ignoring cancelled or superseded requests.
    func load(symbol: String, range: StockChartRange = .day) async {
        guard !Task.isCancelled else {
            return
        }
        let id = UUID()
        requestID = id
        if let cached = cache[symbol]?[range] {
            state = .loaded(cached)
            return
        }
        state = .loading
        do {
            let points = try await service.fetchTimeSeries(
                symbol: symbol,
                range: range
            )
            try Task.checkCancellation()
            guard requestID == id else {
                return
            }
            let filtered = range.filter(points)
            cache[symbol, default: [:]][range] = filtered
            state = .loaded(filtered)
        } catch {
            guard requestID == id,
                  !Task.isCancelled,
                  !(error is CancellationError)
            else {
                return
            }
            state = .failed
        }
    }
}
