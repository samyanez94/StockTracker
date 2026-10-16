//
//  StockPriceChartHeader.swift
//  StockTracker
//
//  Created by Samuel Yanez on 10/16/26.
//

import SwiftUI

/// Adaptive price, daily-change, and timestamp readout above the plot.
struct StockPriceChartHeader: View {
    let data: StockPriceChartData
    let changeColor: Color

    var body: some View {
        if let point = data.displayedPoint {
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
                Text(data.formattedDate(point.date))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            // The parent exposes the complete readout as one adjustable element.
            .accessibilityHidden(true)
        }
    }

    private func priceLabel(_ point: StockPricePoint) -> some View {
        Text("\(data.formattedPrice(point.price)) \(data.currency)")
            .font(.title2.bold())
            .monospacedDigit()
            .fixedSize(horizontal: false, vertical: true)
    }

    private var deltaLabel: some View {
        HStack(alignment: .center, spacing: 6) {
            Text(data.formattedDelta)
            if let delta = data.percentChange, delta != 0 {
                Image(systemName: delta > 0 ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                    .font(.caption)
            }
        }
        .font(.headline)
        .monospacedDigit()
        .foregroundStyle(changeColor)
    }
}
