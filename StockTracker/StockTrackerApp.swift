//
//  StockTrackerApp.swift
//  StockTracker
//
//  Created by Samuel Yanez on 4/27/26.
//

import SwiftUI

@main
struct StockTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            AppFactory.makeWatchListView()
        }
    }
}

enum AppFactory {
    @MainActor
    static func makeWatchListView() -> WatchListView {
        let configuration = AppConfiguration.current
        let watchlistStore = WatchlistStore()
        let savedStocks = watchlistStore.loadStocks()
        return WatchListView(
            viewModel: WatchListViewModel(
                stocks: savedStocks ?? stocks,
                service: StockService(
                    usesMockData: configuration.usesMockData,
                    apiKey: configuration.stockDataAPIKey,
                ),
                watchlistStore: watchlistStore,
            ),
        )
    }

    static let stocks = [
        Stock(symbol: "AAPL", companyName: "Apple Inc."),
        Stock(symbol: "MSFT", companyName: "Microsoft Corporation"),
        Stock(symbol: "TSLA", companyName: "Tesla, Inc."),
    ]
}
