//
//  StockListView.swift
//  StockTracker
//
//  Created by Samuel Yanez on 4/27/26.
//

import SwiftUI

struct StockListView: View {
    @State private var viewModel: StockListViewModel

    init(viewModel: StockListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            List(viewModel.stocks) { stock in
                StockRowView(stock: stock, quote: viewModel.quote(for: stock))
            }
            .navigationTitle("Stocks")
            .task {
                await viewModel.startPolling()
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
    }
}

#Preview {
    StockListView(
        viewModel: StockListViewModel(
            stocks: AppFactory.stocks,
            service: StockService(usesMockData: true),
        ),
    )
}
