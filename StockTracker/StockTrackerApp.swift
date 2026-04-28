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
            AppFactory.makeStockListView()
        }
    }
}

enum AppFactory {
    @MainActor
    static func makeStockListView() -> StockListView {
        StockListView(
            viewModel: StockListViewModel(
                stocks: stocks,
                service: StockService(usesMockData: true),
            ),
        )
    }

    static let stocks = [
        Stock(symbol: "AAPL", companyName: "Apple Inc."),
        Stock(symbol: "MSFT", companyName: "Microsoft"),
        Stock(symbol: "TSLA", companyName: "Tesla"),
    ]
}
