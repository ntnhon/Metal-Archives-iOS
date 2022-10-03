//
//  APIService.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 01/08/2022.
//

import Foundation

protocol APIServiceProtocol {
    var session: URLSession { get }

    func getData(for urlString: String) async throws -> Data
    func request<T: HTMLParsable>(forType type: T.Type, urlString: String) async throws -> T
}

extension APIServiceProtocol {
    func getData(for urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw MAError.badUrlString(urlString)
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw MAError.invalidServerResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            return data
        default:
            throw MAError.requestFailure(httpResponse.statusCode)
        }
    }

    func request<T: HTMLParsable>(forType type: T.Type, urlString: String) async throws -> T {
        let data = try await getData(for: urlString)
        return try T(data: data)
    }
}

final class APIService: APIServiceProtocol {
    let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }
}
