//
//  WatchListSortOption.swift
//  StockTracker
//
//  Created by Samuel Yanez on 4/28/26.
//

import Foundation

nonisolated enum WatchListSortOption: String, CaseIterable, Identifiable {
    case percentageChange
    case symbol
    case name

    var id: Self {
        self
    }

    var title: String {
        switch self {
        case .percentageChange:
            "Percentage Change"
        case .symbol:
            "Symbol"
        case .name:
            "Name"
        }
    }
}

nonisolated enum WatchListSortDirection: String, CaseIterable, Identifiable {
    case ascending
    case descending

    var id: Self {
        self
    }

    var title: String {
        switch self {
        case .ascending:
            "Ascending"
        case .descending:
            "Descending"
        }
    }
}
