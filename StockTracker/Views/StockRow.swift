//
//  StockRow.swift
//  StockTracker
//
//  Created by Samuel Yanez on 4/27/26.
//

import SwiftUI

struct StockRow: View {
    let stock: Stock
    let quote: Quote?

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
            VStack(alignment: .trailing) {
                Text(quote?.formattedPrice ?? "—")
                    .font(.headline)
                Text(quote?.formattedPercentChange ?? "—")
                    .font(.subheadline)
                    .foregroundStyle(percentChangeColor)
            }
        }
    }

    private var percentChangeColor: Color {
        (quote?.percentChange ?? 0) >= 0 ? .green : .red
    }
}
