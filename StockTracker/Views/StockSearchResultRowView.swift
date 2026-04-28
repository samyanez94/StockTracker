//
//  StockSearchResultRowView.swift
//  StockTracker
//
//  Created by Samuel Yanez on 4/28/26.
//

import SwiftUI

struct StockSearchResultRowView: View {
    let stock: Stock

    var body: some View {
        VStack(alignment: .leading) {
            Text(stock.symbol)
                .font(.headline)
            Text(stock.companyName)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
