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

    @State private var viewModel: StockDetailViewModel

    let stock: Stock

    let quote: Quote?

    init(
        stock: Stock,
        quote: Quote?,
        service: any StockServicing
    ) {
        self.stock = stock
        self.quote = quote
        _viewModel = State(
            initialValue: StockDetailViewModel(service: service)
        )
    }

    var body: some View {
        ScrollView {
            cardView
                .background(.background, in: .rect(cornerRadius: 24))
                .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .task(id: stock.symbol) {
            await viewModel.load(symbol: stock.symbol)
        }
        .navigationTitle(stock.symbol)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var cardView: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(stock.companyName)
                        .font(.title.bold())
                        .accessibilityAddTraits(.isHeader)
                    Text(stock.symbol)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                chartView
            }
            .padding(24)

            Divider()

            StockStatsView(quote: quote)
                .padding(24)
        }
    }

    private var chartHeight: CGFloat {
        dynamicTypeSize.isAccessibilitySize ? 280 : 220
    }

    private var chartView: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView("Loading price history")
            case let .loaded(points) where !points.isEmpty:
                StockPriceChart(
                    points: points,
                    currency: quote?.currency ?? "USD",
                    previousClose: quote?.previousClose
                )
            case .loaded:
                Text("No price history available")
                    .foregroundStyle(.secondary)
            case .failed:
                Text("Price history is unavailable right now.")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: chartHeight)
    }
}

#Preview("Quote details") {
    NavigationStack {
        StockDetailView(
            stock: Stock(symbol: "AAPL", companyName: "Apple Inc."),
            quote: Quote(
                symbol: "AAPL",
                price: 204.18,
                percentChange: 0.62,
                change: 1.26,
                open: 203.33,
                previousClose: 202.92,
                volume: 45_000_000,
                averageVolume: 52_000_000,
                low: 201.30,
                high: 206.22,
                fiftyTwoWeekLow: 147.01,
                fiftyTwoWeekHigh: 253.18
            ),
            service: StockService(usesMockData: true)
        )
    }
}

#Preview("Missing statistics") {
    NavigationStack {
        StockDetailView(
            stock: Stock(symbol: "TSLA", companyName: "Tesla, Inc."),
            quote: Quote(symbol: "TSLA", price: 169.28, percentChange: -1.12),
            service: StockService(usesMockData: true)
        )
    }
}

#Preview("No quote") {
    NavigationStack {
        StockDetailView(
            stock: Stock(symbol: "AAPL", companyName: "Apple Inc."),
            quote: nil,
            service: StockService(usesMockData: true)
        )
    }
}
