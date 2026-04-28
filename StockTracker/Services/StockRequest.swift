//
//  StockRequest.swift
//  StockTracker
//
//  Created by Samuel Yanez on 4/27/26.
//

import Foundation

protocol StockRequest {
    associatedtype Response

    var url: URL { get throws }

    func decode(_ data: Data) throws -> Response

    func mockResponse() -> Response?
}

extension StockRequest {
    func mockResponse() -> Response? {
        nil
    }
}
