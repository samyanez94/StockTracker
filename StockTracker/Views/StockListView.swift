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
            List {
                if viewModel.isSearchPresented,
                   !viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                {
                    ForEach(viewModel.searchResults) { stock in
                        StockSearchResultRowView(
                            stock: stock,
                            isInWatchlist: viewModel.isInWatchlist(stock),
                        ) {
                            Task {
                                await viewModel.toggleWatchlistMembership(for: stock)
                            }
                        }
                    }
                } else {
                    ForEach(viewModel.stocks) { stock in
                        StockRowView(stock: stock, quote: viewModel.quote(for: stock))
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    viewModel.removeFromWatchlist(stock)
                                } label: {
                                    Label("Remove", systemImage: "trash")
                                }
                            }
                    }
                }
            }
            .navigationTitle("Stocks")
            .searchable(
                text: $viewModel.searchText,
                isPresented: $viewModel.isSearchPresented,
                placement: .automatic,
                prompt: "Search stocks",
            )
            .onChange(of: viewModel.searchText) {
                Task {
                    await viewModel.search()
                }
            }
            .onChange(of: viewModel.isSearchPresented) { _, isSearchPresented in
                if !isSearchPresented {
                    viewModel.clearSearch()
                }
            }
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
