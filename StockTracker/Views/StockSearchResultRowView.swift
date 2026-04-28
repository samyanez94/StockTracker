//
//  StockSearchResultRowView.swift
//  StockTracker
//
//  Created by Samuel Yanez on 4/28/26.
//

import SwiftUI

struct StockSearchResultRowView: View {
    let stock: Stock
    let isInWatchlist: Bool
    let toggleWatchlistMembership: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(stock.symbol)
                    .font(.headline)
                Text(stock.companyName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                toggleWatchlistMembership()
            } label: {
                Image(systemName: isInWatchlist ? "checkmark.circle.fill" : "plus.circle")
                    .imageScale(.large)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.blue)
            .accessibilityLabel(isInWatchlist ? "Remove from watchlist" : "Add to watchlist")
        }
    }
}
