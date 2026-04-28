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
                    service: StockService(usesMockData: true)
                )
            )
        }
    }
}
