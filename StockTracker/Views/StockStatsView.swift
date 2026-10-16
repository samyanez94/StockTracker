//
//  StockStatsView.swift
//  StockTracker
//
//  Created by Samuel Yanez on 10/16/26.
//

import SwiftUI

/// Quote statistics arranged in two columns, or one at accessibility text sizes.
struct StockStatsView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let quote: Quote?

    private var columns: [GridItem] {
        Array(
            repeating: GridItem(.flexible(), alignment: .leading),
            count: dynamicTypeSize.isAccessibilitySize ? 1 : 2
        )
    }

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 16) {
            statistic("Open", value: quote?.formattedOpen)
            statistic("Previous Close", value: quote?.formattedPreviousClose)
            statistic("Volume", value: quote?.formattedVolume)
            statistic("Average Volume", value: quote?.formattedAverageVolume)
            statistic("Today's High", value: quote?.formattedHigh)
            statistic("Today's Low", value: quote?.formattedLow)
            statistic("52-Week High", value: quote?.formattedFiftyTwoWeekHigh)
            statistic("52-Week Low", value: quote?.formattedFiftyTwoWeekLow)
        }
    }

    private func statistic(_ title: String, value: String?) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(value ?? "—")
                .font(.headline)
                .monospacedDigit()
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}
