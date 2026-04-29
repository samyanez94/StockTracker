//
//  WatchListView.swift
//  StockTracker
//
//  Created by Samuel Yanez on 4/27/26.
//

import SwiftUI

struct WatchListView: View {
    @State private var viewModel: WatchListViewModel

    init(viewModel: WatchListViewModel) {
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
                    ForEach(viewModel.sortedStocks) { stock in
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
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Sort By", selection: $viewModel.sortOption) {
                            ForEach(WatchListSortOption.allCases) { option in
                                Text(option.title).tag(option)
                            }
                        }
                        Picker("Direction", selection: $viewModel.sortDirection) {
                            ForEach(WatchListSortDirection.allCases) { direction in
                                Text(direction.title).tag(direction)
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                    .accessibilityLabel("Sort watchlist")
                }
            }
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
    WatchListView(
        viewModel: WatchListViewModel(
            stocks: AppFactory.stocks,
            service: StockService(usesMockData: true),
            watchlistStore: WatchlistStore(),
        ),
    )
}
