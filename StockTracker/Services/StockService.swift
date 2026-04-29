//
//  StockService.swift
//  StockTracker
//
//  Created by Samuel Yanez on 4/27/26.
//

import Foundation

protocol StockServicing {
    func fetch<Request: StockRequest>(_ request: Request) async throws -> Request.Response
}

struct StockService: StockServicing {
    private let usesMockData: Bool
    private let apiKey: String

    init(
        usesMockData: Bool = false,
        apiKey: String = Secrets.stockDataAPIKey,
    ) {
        self.usesMockData = usesMockData
        self.apiKey = apiKey
    }

    func fetch<Request: StockRequest>(_ request: Request) async throws -> Request.Response {
        if usesMockData, let mockResponse = request.mockResponse() {
            return mockResponse
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
