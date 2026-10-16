//
//  StockPriceChart.swift
//  StockTracker
//
//  Created by Samuel Yanez on 10/16/26.
//

import Charts
import SwiftUI

/// Renders chronological closing prices with a smooth line and a subtle area fill.
struct StockPriceChart: View {
    let points: [StockPricePoint]
    let currency: String
    let percentChange: Double

    private var changeColor: Color {
        percentChange > 0 ? .green : .red
    }

    private var priceDomain: ClosedRange<Double> {
        let low = points.map(\.price).min() ?? 0
        let high = points.map(\.price).max() ?? low
        let padding = max((high - low) * 0.15, max(abs(high) * 0.002, 0.01))
        return max(0, low - padding) ... (high + padding)
    }

    private var dateDomain: ClosedRange<Date> {
        let first = points.first?.date ?? .distantPast
        let last = points.last?.date ?? first
        return first == last ? first.addingTimeInterval(-150) ... last.addingTimeInterval(150) : first ... last
    }

    private var timeZone: TimeZone {
        points.first?.timeZone ?? .gmt
    }

    private func dateLabel(_ date: Date) -> String {
        date.formatted(Date.FormatStyle(date: .abbreviated, time: .shortened, timeZone: timeZone))
    }

    var body: some View {
        Chart {
            ForEach(points) { point in
                AreaMark(
                    x: .value("Time", point.date),
                    yStart: .value("Baseline", priceDomain.lowerBound),
                    yEnd: .value("Price", point.price)
                )
                .interpolationMethod(.monotone)
                .foregroundStyle(
                    LinearGradient(
                        colors: [changeColor.opacity(0.22), changeColor.opacity(0)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                LineMark(
                    x: .value("Time", point.date),
                    y: .value("Price", point.price)
                )
                .interpolationMethod(.monotone)
                .lineStyle(
                    StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
                )
                .foregroundStyle(changeColor)
            }
            if let latest = points.last {
                PointMark(
                    x: .value("Time", latest.date),
                    y: .value("Price", latest.price)
                )
                .symbolSize(36)
                .foregroundStyle(changeColor)
            }
        }
        .chartXScale(domain: dateDomain)
        .chartYScale(domain: priceDomain)
        .chartXAxis(.hidden)
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) { _ in
                AxisGridLine().foregroundStyle(.secondary.opacity(0.15))
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Recent stock prices")
        .accessibilityValue(summary)
    }

    private var summary: String {
        guard let first = points.first,
              let last = points.last,
              let low = points.map(\.price).min(),
              let high = points.map(\.price).max()
        else {
            return "No price history available"
        }
        let format = FloatingPointFormatStyle<Double>.Currency(code: currency)
        return "From \(dateLabel(first.date)) to \(dateLabel(last.date)). Low \(low.formatted(format)), high \(high.formatted(format)). Latest \(last.price.formatted(format))."
    }
}

#Preview("Flat prices") {
    StockPriceChart(
        points: (0 ..< 10).map {
            StockPricePoint(
                date: Date(timeIntervalSince1970: 1_792_072_800 + Double($0) * 300),
                price: 100
            )
        },
        currency: "USD",
        percentChange: 0
    )
    .frame(height: 220)
    .padding()
}

#Preview("Single price") {
    StockPriceChart(
        points: [StockPricePoint(date: .now, price: 100)],
        currency: "USD",
        percentChange: 0
    )
    .frame(height: 220)
    .padding()
}
