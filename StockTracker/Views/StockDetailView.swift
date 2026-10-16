//
//  StockDetailView.swift
//  StockTracker
//
//  Created by Samuel Yanez on 10/14/26.
//

import SwiftUI
import UIKit

/// Displays a stock's identity, latest quote, and available trading statistics.
struct StockDetailView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let stock: Stock

    let quote: Quote?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(stock.companyName)
                            .font(.title.bold())
                            .accessibilityAddTraits(.isHeader)
                        Text(stock.symbol)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    ViewThatFits(in: .horizontal) {
                        HStack(alignment: .firstTextBaseline, spacing: 24) {
                            price
                            Spacer(minLength: 0)
                            dailyChange
                        }
                        VStack(alignment: .leading, spacing: 12) {
                            price
                            dailyChange
                        }
                    }
                }
                .padding(24)

                Divider()

                LazyVGrid(
                    columns: Array(
                        repeating: GridItem(.flexible(), alignment: .leading),
                        count: dynamicTypeSize.isAccessibilitySize ? 1 : 2
                    ),
                    alignment: .leading,
                    spacing: 16
                ) {
                    statistic("Open", value: quote?.formattedOpen)
                    statistic("Previous Close", value: quote?.formattedPreviousClose)
                    statistic("Volume", value: quote?.formattedVolume)
                    statistic("Average Volume", value: quote?.formattedAverageVolume)
                    statistic("Day Range", value: quote?.formattedDayRange)
                    statistic("52-Week Range", value: quote?.formattedFiftyTwoWeekRange)
                }
                .padding(24)
            }
            .background(.background, in: .rect(cornerRadius: 24))
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle(stock.symbol)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var price: some View {
        Text(quote?.formattedPriceWithCurrency ?? "Price unavailable")
            .font(.title2.bold())
            .monospacedDigit()
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityLabel("Latest price")
            .accessibilityValue(quote?.formattedPriceWithCurrency ?? "Unavailable")
    }

    private var dailyChange: some View {
        HStack(alignment: .center, spacing: 6) {
            Text(quote?.formattedPercentChange ?? "—")
            if let change = quote?.percentChange,
                change != 0 {
                Image(systemName: change > 0 ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                    .font(.caption)
                    .accessibilityHidden(true)
            }
        }
        .font(.headline)
        .foregroundStyle((quote?.percentChange ?? 0) >= 0 ? Color.green : Color.red)
        .monospacedDigit()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Daily change")
        .accessibilityValue(quote?.formattedPercentChange ?? "Unavailable")
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

#Preview("Quote details") {
    NavigationStack {
        StockDetailView(
            stock: Stock(symbol: "AAPL", companyName: "Apple Inc."),
            quote: Quote(
                symbol: "AAPL", price: 204.18, percentChange: 0.62,
                change: 1.26, open: 203.33, previousClose: 202.92,
                volume: 45_000_000, averageVolume: 52_000_000,
                low: 201.30, high: 206.22, fiftyTwoWeekLow: 147.01, fiftyTwoWeekHigh: 253.18
            )
        )
    }
}

#Preview("Missing statistics") {
    NavigationStack {
        StockDetailView(
            stock: Stock(symbol: "TSLA", companyName: "Tesla, Inc."),
            quote: Quote(symbol: "TSLA", price: 169.28, percentChange: -1.12)
        )
    }
}

#Preview("No quote") {
    NavigationStack {
        StockDetailView(
            stock: Stock(symbol: "AAPL", companyName: "Apple Inc."),
            quote: nil
        )
    }
}
