//
//  RequestReview.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 06/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

extension RequestHelper {
    final class ReviewDetail {
        typealias FetchReviewOnSuccess = (_ review: Review) -> Void
        typealias FetchReviewOnError = (Error) -> Void
        
        static func fetchReview(urlString: String, onSuccess: @escaping FetchReviewOnSuccess, onError: @escaping FetchReviewOnError) {
            guard let requestURL = URL(string: urlString) else {
                onError(MANetworkingError.badURL(urlString))
                return
            }
            
            RequestHelper.shared.alamofireManager.request(requestURL).responseData { (response) in
                switch response.result {
                case .success:
                    if let data = response.data, let review = Review(data: data) {
                        onSuccess(review)
                    } else {
                        onError(MANetworkingError.badResponse(response))
                    }
                    
                case .failure(let error): onError(error)
                }
            }
        }
    }
}
