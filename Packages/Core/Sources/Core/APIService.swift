//
//  APIService.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 05/04/2024.
//

import Foundation
import Models

public protocol APIServiceProtocol: Sendable {
    func getData(for urlString: String) async throws -> Data
    func getString(for urlString: String, inHtmlFormat: Bool) async throws -> String?
    func request<T: HTMLParsable>(forType type: T.Type, urlString: String) async throws -> T
}

public final class APIService: APIServiceProtocol {
    let session: URLSession
    let htmlSanitizer: any HTMLSanitizer

    public init(session: URLSession = .shared,
                htmlSanitizer: any HTMLSanitizer)
    {
        self.session = session
        self.htmlSanitizer = htmlSanitizer
    }
}

public extension APIService {
    func getData(for urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw MAError.badUrlString(urlString)
        }

        let (data, response) = try await Task.retrying(
            description: urlString,
            operation: { [weak self] in
                guard let self else {
                    throw MAError.deallocatedSelf
                }
                return try await session.data(from: url)
            },
            shouldRetry: { _, response in
                (response as? HTTPURLResponse)?.statusCode == 429
            }
        ).value

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

        guard let htmlString = String(data: data, encoding: .utf8) else {
            throw MAError.failedToUtf8DecodeString
        }

        return if inHtmlFormat {
            htmlString.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            htmlSanitizer.sanitize(html: htmlString)
        }
    }

    func request<T: HTMLParsable>(forType _: T.Type, urlString: String) async throws -> T {
        let data = try await getData(for: urlString)
        return try T(data: data)
    }
}

// https://www.swiftbysundell.com/articles/retrying-an-async-swift-task/
extension Task where Failure == any Error {
    @discardableResult
    static func retrying(
        priority: TaskPriority? = nil,
        maxRetryCount: Int = 3,
        retryDelayInSeconds: Int = 4,
        description: String? = nil,
        operation: @Sendable @escaping () async throws -> Success,
        shouldRetry: @Sendable @escaping (Success) -> Bool
    ) -> Task {
        Task(priority: priority) {
            for attempt in 1 ... maxRetryCount {
                let result = try await operation()
                if shouldRetry(result) {
                    let seconds = retryDelayInSeconds * attempt
                    print("Retrying \(attempt) attempt. Wait for \(seconds) seconds.")
                    if let description {
                        print(description)
                        print("\n")
                    }
                    try await Task<Never, Never>.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                } else {
                    return result
                }
            }

            try Task<Never, Never>.checkCancellation()
            return try await operation()
        }
    }
}
