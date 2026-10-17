//
//  StockChartRange.swift
//  StockTracker
//
//  Created by Samuel Yanez on 10/17/26.
//

import Foundation

/// Calendar windows ending at the newest available exchange-local trading date.
nonisolated enum StockChartRange: String, CaseIterable, Identifiable {
    case day = "1D"
    case week = "1W"
    case month = "1M"
    case year = "1Y"

    var id: String {
        rawValue
    }

    var interval: String {
        switch self {
        case .day: "5min"
        case .week: "30min"
        case .month: "1day"
        case .year: "1week"
        }
    }

    /// Overfetch slightly; calendar filtering determines the visible window.
    var outputSize: Int {
        switch self {
        case .day: 78
        case .week: 104
        case .month: 32
        case .year: 54
        }
    }

    var isIntraday: Bool {
        self == .day || self == .week
    }

    var baselineLabel: String {
        self == .day ? "Previous close" : "Period starting price"
    }

    var changeLabel: String {
        self == .day ? "Daily change" : "Period change"
    }

    func filter(_ points: [StockPricePoint]) -> [StockPricePoint] {
        guard let latest = points.max(by: { $0.date < $1.date }) else {
            return []
        }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = latest.timeZone
        let end = calendar.startOfDay(for: latest.date)
        let start: Date
        switch self {
        case .day:
            start = end
        case .week:
            start = calendar.date(byAdding: .day, value: -7, to: end) ?? end
        case .month:
            start = calendar.date(byAdding: .month, value: -1, to: end) ?? end
        case .year:
            start = calendar.date(byAdding: .year, value: -1, to: end) ?? end
        }
        return points.filter {
            $0.date >= start && $0.date <= latest.date
        }
        .sorted { $0.date < $1.date }
    }
}
