//
//  ReviewRequests.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 06/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

extension RequestHelper {
    final class ReviewDetail {}
}

extension RequestHelper.ReviewDetail {
    static func fetchReview(urlString: String, completion: @escaping (Result<Review, MAError>) -> Void) {
        guard let requestUrl = URL(string: urlString) else {
            completion(.failure(.networking(error: .badURL(urlString))))
            return
        }
        
        RequestHelper.shared.alamofireManager.request(requestUrl).responseData { response in
            switch response.result {
            case .success(let data):
                if let review = Review(data: data) {
                    completion(.success(review))
                } else {
                    completion(.failure(.parsing(error: .badStructure(anyObject: Review.self))))
                }
                
            case .failure(let error):
                completion(.failure(.unknown(description: error.localizedDescription)))
            }
        }
    }
}
