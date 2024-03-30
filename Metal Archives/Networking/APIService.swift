//
//  APIService.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 01/08/2022.
//

import Foundation
import Kanna

protocol APIServiceProtocol {
    var session: URLSession { get }

    func getData(for urlString: String) async throws -> Data
    func getString(for urlString: String, inHtmlFormat: Bool) async throws -> String?
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
        case 200 ... 299:
            return data
        default:
            throw MAError.requestFailure(httpResponse.statusCode)
        }
    }

    func getString(for urlString: String, inHtmlFormat: Bool) async throws -> String? {
        let data = try await getData(for: urlString)

        if !inHtmlFormat, let htmlDoc = try? Kanna.HTML(html: data, encoding: .utf8) {
            return htmlDoc.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        guard let string = String(data: data, encoding: .utf8) else {
            throw MAError.failedToUtf8DecodeString
        }
        return string.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func request<T: HTMLParsable>(forType _: T.Type, urlString: String) async throws -> T {
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
