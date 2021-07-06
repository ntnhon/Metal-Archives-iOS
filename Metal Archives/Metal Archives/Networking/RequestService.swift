//
//  RequestService.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/06/2021.
//

import Combine
import Foundation

enum RequestService {
    static func request<T: HTMLParsable>(type: T.Type, from urlString: String) -> AnyPublisher<T, MAError> {
        guard let url = URL(string: urlString) else {
            return Fail(error: MAError.badUrlString(urlString))
                .eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw MAError.invalidServerResponse
                }

                switch httpResponse.statusCode {
                case 200...299:
                    if let object = T(data: data) {
                        return object
                    } else {
                        throw MAError.parseFailure(String(describing: T.self))
                    }
                default: throw MAError.requestFailure(httpResponse.statusCode)
                }
            }
            .mapError { error in
                if let maError = error as? MAError {
                    return maError
                }
                return .other(error)
            }
            .eraseToAnyPublisher()
    }
}
