//
//  WatchListSorter.swift
//  StockTracker
//
//  Created by Samuel Yanez on 4/28/26.
//

import Foundation

nonisolated struct WatchListSorter {
    func sortedStocks(
        _ stocks: [Stock],
        quotes: [String: Quote],
        sortOption: WatchListSortOption,
        sortDirection: WatchListSortDirection,
    ) -> [Stock] {
        switch sortOption {
        case .percentageChange:
            stocks.sorted { lhs, rhs in
                let lhsPercentChange = quotes[lhs.symbol]?.percentChange
                let rhsPercentChange = quotes[rhs.symbol]?.percentChange

                switch (lhsPercentChange, rhsPercentChange) {
                case let (lhsPercentChange?, rhsPercentChange?):
                    if lhsPercentChange == rhsPercentChange {
                        return isSymbolAscending(lhs, rhs, direction: .ascending)
                    }
                    return sortDirection == .ascending
                        ? lhsPercentChange < rhsPercentChange
                        : lhsPercentChange > rhsPercentChange
                case (.some, nil):
                    return true
                case (nil, .some):
                    return false
                case (nil, nil):
                    return isSymbolAscending(lhs, rhs, direction: .ascending)
                }
            }
        case .symbol:
            stocks.sorted {
                isSymbolAscending($0, $1, direction: sortDirection)
            }
        case .name:
            stocks.sorted {
                isCompanyNameAscending($0, $1, direction: sortDirection)
            }
        }
    }

    private func isSymbolAscending(
        _ lhs: Stock,
        _ rhs: Stock,
        direction: WatchListSortDirection,
    ) -> Bool {
        let comparison = lhs.symbol.localizedStandardCompare(rhs.symbol)
        return direction == .ascending
            ? comparison == .orderedAscending
            : comparison == .orderedDescending
    }

    private func isCompanyNameAscending(
        _ lhs: Stock,
        _ rhs: Stock,
        direction: WatchListSortDirection,
    ) -> Bool {
        let comparison = lhs.companyName.localizedStandardCompare(rhs.companyName)
        return direction == .ascending
            ? comparison == .orderedAscending
            : comparison == .orderedDescending
    }
}
