//
//  APIService.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 01/08/2022.
//

import Foundation

protocol APIServiceProtocol {
    var session: URLSession { get }

    func request<T: HTMLParsable>(forType type: T.Type, urlString: String) async throws -> T
}

extension APIServiceProtocol {
    func request<T: HTMLParsable>(forType type: T.Type, urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw MAError.badUrlString(urlString)
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw MAError.invalidServerResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            return try T(data: data)

        default:
            throw MAError.requestFailure(httpResponse.statusCode)
        }
    }
}

final class APIService: APIServiceProtocol {
    let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }
}
