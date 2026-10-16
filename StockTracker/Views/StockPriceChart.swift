//
//  StockPriceChart.swift
//  StockTracker
//
//  Created by Samuel Yanez on 10/16/26.
//

import Charts
import SwiftUI

/// Interactive price history with a previous-close reference and a shared readout.
struct StockPriceChart: View {
    @State private var selectedDate: Date?

    let points: [StockPricePoint]
    let currency: String
    let previousClose: Double?

    private var data: StockPriceChartData {
        StockPriceChartData(
            points: points, currency: currency,
            previousClose: previousClose, selectedDate: selectedDate
        )
    }

    private var changeColor: Color {
        (data.percentChange ?? 0) > 0 ? .green : .red
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            StockPriceChartHeader(data: data, changeColor: changeColor)
            plot
        }
        .onChange(of: points) { clearSelection() }
        .onDisappear { clearSelection() }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Stock price chart")
        .accessibilityValue(data.accessibilityValue)
        .accessibilityHint("Swipe up or down to explore prices.")
        .accessibilityAdjustableAction { adjustSelection($0) }
        .accessibilityAction(named: "Show latest price") { clearSelection() }
    }

    private var plot: some View {
        let priceDomain = data.priceDomain
        return Chart {
            ForEach(points) { point in
                priceMarks(for: point, baseline: priceDomain.lowerBound)
            }
            previousCloseMark
            selectionMark
            highlightedPointMark
        }
        .chartXSelection(value: $selectedDate)
        .chartGesture { proxy in
            DragGesture(minimumDistance: 10)
                .onChanged { proxy.selectXValue(at: $0.location.x) }
                .onEnded { _ in clearSelection() }
        }
        .chartXScale(domain: data.dateDomain)
        .chartYScale(domain: priceDomain)
        .chartXAxis(.hidden)
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) { _ in
                AxisGridLine().foregroundStyle(.secondary.opacity(0.15))
            }
        }
    }

    @ChartContentBuilder
    private func priceMarks(for point: StockPricePoint, baseline: Double) -> some ChartContent {
        AreaMark(
            x: .value("Time", point.date),
            yStart: .value("Baseline", baseline),
            yEnd: .value("Price", point.price)
        )
        .interpolationMethod(.monotone)
        .foregroundStyle(LinearGradient(
            colors: [changeColor.opacity(0.22), changeColor.opacity(0)],
            startPoint: .top, endPoint: .bottom
        ))
        LineMark(x: .value("Time", point.date), y: .value("Price", point.price))
            .interpolationMethod(.monotone)
            .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
            .foregroundStyle(changeColor)
    }

    @ChartContentBuilder
    private var previousCloseMark: some ChartContent {
        if let baseline = data.previousCloseBaseline {
            RuleMark(y: .value("Previous close", baseline))
                .foregroundStyle(.secondary.opacity(0.65))
                .lineStyle(StrokeStyle(lineWidth: 1, lineCap: .round, dash: [1, 4]))
        }
    }

    @ChartContentBuilder
    private var selectionMark: some ChartContent {
        if let point = data.selectedPoint {
            RuleMark(x: .value("Selected time", point.date))
                .foregroundStyle(.secondary.opacity(0.5))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
        }
    }

    @ChartContentBuilder
    private var highlightedPointMark: some ChartContent {
        if let point = data.displayedPoint {
            PointMark(x: .value("Time", point.date), y: .value("Price", point.price))
                .symbolSize(36)
                .foregroundStyle(changeColor)
        }
    }

    private func clearSelection() {
        selectedDate = nil
    }

    private func adjustSelection(_ direction: AccessibilityAdjustmentDirection) {
        guard !points.isEmpty else {
            return
        }
        let current = data.selectedPoint.flatMap { points.firstIndex(of: $0) } ?? (points.count - 1)
        switch direction {
        case .increment:
            selectedDate = points[min(current + 1, points.count - 1)].date
        case .decrement:
            selectedDate = points[max(current - 1, 0)].date
        @unknown default: break
        }
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
