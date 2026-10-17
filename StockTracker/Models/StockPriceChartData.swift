//
//  StockPriceChartData.swift
//  StockTracker
//
//  Created by Samuel Yanez on 10/16/26.
//

import Foundation

/// Derived values shared by the chart's plot, readout, and accessibility description.
struct StockPriceChartData {
    let points: [StockPricePoint]
    let currency: String
    let previousClose: Double?
    var range: StockChartRange = .day
    let selectedDate: Date?

    var selectedPoint: StockPricePoint? {
        guard let selectedDate else {
            return nil
        }
        return StockPriceSelection.nearest(to: selectedDate, in: points)
    }

    var displayedPoint: StockPricePoint? {
        selectedPoint ?? points.last
    }

    var percentChange: Double? {
        displayedPoint?.percentChange(from: previousClose)
    }

    var previousCloseBaseline: Double? {
        guard let previousClose,
              previousClose.isFinite,
              previousClose > 0
        else {
            return nil
        }
        return previousClose
    }

    var priceDomain: ClosedRange<Double> {
        let prices = points.map(\.price) + [previousCloseBaseline].compactMap { $0 }
        let low = prices.min() ?? 0
        let high = prices.max() ?? low
        let padding = max((high - low) * 0.15, max(abs(high) * 0.002, 0.01))
        return max(0, low - padding) ... (high + padding)
    }

    var dateDomain: ClosedRange<Date> {
        let first = points.first?.date ?? .distantPast
        let last = points.last?.date ?? first
        guard first != last else {
            return first.addingTimeInterval(-150) ... last.addingTimeInterval(150)
        }
        return first ... last
    }

    var formattedDelta: String {
        guard let percentChange else { return "—" }
        let sign = percentChange >= 0 ? "+" : ""
        return sign + percentChange.formatted(.number.precision(.fractionLength(2))) + "%"
    }

    func formattedPrice(_ price: Double) -> String {
        price.formatted(.currency(code: currency).precision(.fractionLength(2)))
    }

    func formattedDate(_ date: Date) -> String {
        date.formatted(Date.FormatStyle(
            date: .abbreviated, time: range.isIntraday ? .shortened : .omitted,
            timeZone: points.first?.timeZone ?? .gmt
        ))
    }

    var accessibilityValue: String {
        let description: String
        if let selectedPoint {
            description = "\(selectedPoint.price.formatted(.currency(code: currency))), \(formattedDate(selectedPoint.date))"
        } else {
            description = summary
        }
        return description + ". \(range.changeLabel) \(formattedDelta)"
    }

    private var summary: String {
        guard let first = points.first, let last = points.last,
              let low = points.map(\.price).min(), let high = points.map(\.price).max()
        else {
            return "No price history available"
        }
        let format = FloatingPointFormatStyle<Double>.Currency(code: currency)
        let baseline = previousCloseBaseline.map { " \(range.baselineLabel) \($0.formatted(format))." } ?? ""
        return "From \(formattedDate(first.date)) to \(formattedDate(last.date)). Low \(low.formatted(format)), high \(high.formatted(format)). Latest \(last.price.formatted(format))." + baseline
    }
}
