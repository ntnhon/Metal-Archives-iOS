//
//  RequestService+Review.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 07/05/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

extension RequestService {
    final class Review {
        private init() {}
    }
}

extension RequestService.Review {
    static func fetch(urlString: String, completion: @escaping (Result<Review, MAError>) -> Void) {
        guard let requestUrl = URL(string: urlString) else {
            completion(.failure(.networking(error: .badURL(urlString))))
            return
        }
        
        RequestService.shared.alamofireSession.request(requestUrl).responseData { response in
            switch response.result {
            case .success(let data):
                if let review = Review(data: data) {
                    completion(.success(review))
                } else {
                    completion(.failure(.parsing(error: .badStructure(anyObject: Review.self))))
                }
                
            case .failure(let error):
                completion(.failure(.alamofire(error: error)))
            }
        }
    }
}
