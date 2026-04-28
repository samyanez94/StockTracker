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
            StockListView(
                viewModel: StockListViewModel(
                    stocks: [
                        Stock(symbol: "AAPL", companyName: "Apple Inc."),
                        Stock(symbol: "MSFT", companyName: "Microsoft"),
                        Stock(symbol: "TSLA", companyName: "Tesla"),
                    ],
                    service: StockService(usesMockData: true),
                ),
            )
        }
    }
}
