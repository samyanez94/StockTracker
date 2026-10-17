//
//  StockService.swift
//  StockTracker
//
//  Created by Samuel Yanez on 4/27/26.
//

import Foundation

/// Provides stock quotes, price history, and search results independently of the data provider.
///
/// Implementations can supply live data or test responses without exposing request types.
nonisolated protocol StockServicing {
    /// Loads quotes for the requested stock symbols.
    /// - Parameter symbols: The symbols to look up.
    /// - Returns: Quotes for the requested symbols, or an empty array for an empty list.
    /// - Throws: An error if the quotes cannot be loaded or decoded.
    func fetchQuotes(symbols: [String]) async throws -> [Quote]

    /// Loads closing prices for the requested chart range, ordered oldest first.
    /// - Throws: A request, networking, API, or decoding error.
    func fetchTimeSeries(symbol: String, range: StockChartRange) async throws -> [StockPricePoint]

    /// Finds stocks matching a symbol or company name.
    /// - Parameter query: The search text.
    /// - Returns: Stocks matching the query.
    /// - Throws: An error if the search cannot be completed or decoded.
    func searchStocks(query: String) async throws -> [Stock]
}

extension StockServicing {
    /// Convenience for the default intraday range.
    func fetchTimeSeries(symbol: String) async throws -> [StockPricePoint] {
        try await fetchTimeSeries(symbol: symbol, range: .day)
    }
}

/// Provides quotes, price history, and search using Twelve Data requests and local mock JSON.
///
/// Both modes use the request's decoder. Mock mode never falls back to networking.
struct StockService: StockServicing {
    private let usesMockData: Bool

    private let apiKey: String

    /// Creates a service with a fixed data source and API key.
    /// - Parameters:
    ///   - usesMockData: Whether to decode local mock data instead of making HTTP requests.
    ///   - apiKey: The API key used for live requests; mock mode does not require a key.
    init(
        usesMockData: Bool = false,
        apiKey: String = Secrets.twelveDataAPIKey
    ) {
        self.usesMockData = usesMockData
        self.apiKey = apiKey
    }

    /// Loads Twelve Data quotes for the supplied symbols.
    /// - Parameter symbols: The symbols to look up.
    /// - Returns: Quotes in request order, or an empty array without making a request
    ///   when no symbols are supplied.
    /// - Throws: A mock-data, request, networking, API, or decoding error.
    @MainActor
    func fetchQuotes(symbols: [String]) async throws -> [Quote] {
        guard !symbols.isEmpty else {
            return []
        }
        return try await fetch(TwelveDataQuoteRequest(symbols: symbols))
    }

    /// Loads recent price history through the configured live or mock data source.
    /// - Returns: Chronological points, or an empty array when the provider has no bars.
    /// - Throws: A mock-data, request, networking, API, or decoding error.
    @MainActor
    func fetchTimeSeries(symbol: String, range: StockChartRange) async throws -> [StockPricePoint] {
        try await fetch(TwelveDataTimeSeriesRequest(symbol: symbol, range: range))
    }

    /// Searches Twelve Data for US common stocks quoted in USD.
    /// - Parameter query: A stock symbol or company name to search for.
    /// - Returns: Matching stocks, deduplicated by symbol.
    /// - Throws: A mock-data, request, networking, API, or decoding error.
    @MainActor
    func searchStocks(query: String) async throws -> [Stock] {
        try await fetch(TwelveDataSearchRequest(query: query))
    }

    /// Decodes mock JSON or fetches and decodes a successful HTTP response.
    /// - Parameter request: The request to execute.
    /// - Returns: The decoded domain response.
    /// - Throws: `StockServiceError.missingMockData` when mock data is unavailable,
    ///   or a URL-construction, networking, HTTP-validation, API, or decoding error.
    @MainActor
    private func fetch<Request: StockRequest>(_ request: Request) async throws -> Request.Response {
        if usesMockData {
            guard let data = try request.mockData() else {
                throw StockServiceError.missingMockData
            }
            return try request.decode(data)
        }
        let (data, response) = try await URLSession.shared.data(from: request.url(apiKey: apiKey))

        try validate(response)

        return try request.decode(data)
    }

    private func validate(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw StockServiceError.invalidResponse
        }
        guard (200 ... 299).contains(httpResponse.statusCode) else {
            throw StockServiceError.badStatusCode(httpResponse.statusCode)
        }
    }
}
