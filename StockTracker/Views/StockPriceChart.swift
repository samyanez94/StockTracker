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
    @State private var selectedDate: Date?

    let points: [StockPricePoint]

    let currency: String

    let previousClose: Double?

    private var changeColor: Color {
        (displayedDelta ?? 0) > 0 ? .green : .red
    }

    private var previousCloseBaseline: Double? {
        guard let previousClose,
              previousClose.isFinite,
              previousClose > 0
        else {
            return nil
        }
        return previousClose
    }

    private var priceDomain: ClosedRange<Double> {
        let prices = points.map(\.price) + [previousCloseBaseline].compactMap { $0 }
        let low = prices.min() ?? 0
        let high = prices.max() ?? low
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

    private var selectedPoint: StockPricePoint? {
        guard let selectedDate else { return nil }
        return StockPriceSelection.nearest(to: selectedDate, in: points)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let point = selectedPoint ?? points.last {
                VStack(alignment: .leading, spacing: 2) {
                    ViewThatFits(in: .horizontal) {
                        HStack(alignment: .firstTextBaseline) {
                            priceLabel(point)
                            Spacer(minLength: 12)
                            deltaLabel
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            priceLabel(point)
                            deltaLabel
                        }
                    }
                    Text(dateLabel(point.date))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .accessibilityHidden(true)
            }
            plot
        }
        .onChange(of: points) { selectedDate = nil }
        .onDisappear { selectedDate = nil }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Stock price chart")
        .accessibilityValue((selectedPoint.map { "\($0.price.formatted(.currency(code: currency))), \(dateLabel($0.date))" } ?? summary) + ". Daily change \(formattedDelta)")
        .accessibilityHint("Swipe up or down to explore prices.")
        .accessibilityAdjustableAction { direction in
            guard !points.isEmpty else {
                return
            }
            let current = selectedPoint.flatMap { points.firstIndex(of: $0) } ?? (points.count - 1)
            switch direction {
            case .increment:
                selectedDate = points[min(current + 1, points.count - 1)].date
            case .decrement:
                selectedDate = points[max(current - 1, 0)].date
            @unknown default: break
            }
        }
        .accessibilityAction(named: "Show latest price") { selectedDate = nil }
    }

    private func priceLabel(_ point: StockPricePoint) -> some View {
        Text("\(point.price.formatted(.currency(code: currency).precision(.fractionLength(2)))) \(currency)")
            .font(.title2.bold())
            .monospacedDigit()
            .fixedSize(horizontal: false, vertical: true)
    }

    private var displayedDelta: Double? {
        (selectedPoint ?? points.last)?.percentChange(from: previousClose)
    }

    private var formattedDelta: String {
        guard let delta = displayedDelta else { return "—" }
        return (delta >= 0 ? "+" : "") + delta.formatted(.number.precision(.fractionLength(2))) + "%"
    }

    private var deltaLabel: some View {
        HStack(alignment: .center, spacing: 6) {
            Text(formattedDelta)
            if let delta = displayedDelta, delta != 0 {
                Image(systemName: delta > 0 ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                    .font(.caption)
            }
        }
        .font(.headline)
        .monospacedDigit()
        .foregroundStyle((displayedDelta ?? 0) > 0 ? Color.green : Color.red)
    }

    private var plot: some View {
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
            if let previousCloseBaseline {
                RuleMark(y: .value("Previous close", previousCloseBaseline))
                    .foregroundStyle(.secondary.opacity(0.65))
                    .lineStyle(StrokeStyle(lineWidth: 1, lineCap: .round, dash: [1, 4]))
            }
            if let selectedPoint {
                RuleMark(x: .value("Selected time", selectedPoint.date))
                    .foregroundStyle(.secondary.opacity(0.5))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
            }
            if let latest = selectedPoint ?? points.last {
                PointMark(
                    x: .value("Time", latest.date),
                    y: .value("Price", latest.price)
                )
                .symbolSize(36)
                .foregroundStyle(changeColor)
            }
        }
        .chartXSelection(value: $selectedDate)
        .chartGesture { proxy in
            DragGesture(minimumDistance: 10)
                .onChanged { proxy.selectXValue(at: $0.location.x) }
                .onEnded { _ in selectedDate = nil }
        }
        .chartXScale(domain: dateDomain)
        .chartYScale(domain: priceDomain)
        .chartXAxis(.hidden)
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) { _ in
                AxisGridLine().foregroundStyle(.secondary.opacity(0.15))
            }
        }
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
        let baseline = previousCloseBaseline.map { " Previous close \($0.formatted(format))." } ?? ""
        return "From \(dateLabel(first.date)) to \(dateLabel(last.date)). Low \(low.formatted(format)), high \(high.formatted(format)). Latest \(last.price.formatted(format))." + baseline
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
        previousClose: 100
    )
    .frame(height: 220)
    .padding()
}

#Preview("Single price") {
    StockPriceChart(
        points: [StockPricePoint(date: .now, price: 100)],
        currency: "USD",
        previousClose: 100
    )
    .frame(height: 220)
    .padding()
}
