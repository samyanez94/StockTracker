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

    /// Loads the latest available exchange-local trading day, ignoring cancelled or superseded results.
    func load(symbol: String) async {
        let id = UUID()
        requestID = id
        state = .loading
        do {
            let points = try await service.fetchTimeSeries(symbol: symbol)
            try Task.checkCancellation()
            guard requestID == id else {
                return
            }
            state = .loaded(latestSession(in: points))
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

    /// US regular-session bars belong to the session identified by their exchange-local date.
    ///
    /// Using the newest bar rather than today also handles weekends, holidays, and pre-open hours.
    private func latestSession(in points: [StockPricePoint]) -> [StockPricePoint] {
        guard let latest = points.max(by: { $0.date < $1.date }) else {
            return []
        }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = latest.timeZone
        return points.filter {
            calendar.isDate($0.date, inSameDayAs: latest.date)
        }
        .sorted { $0.date < $1.date }
    }
}
