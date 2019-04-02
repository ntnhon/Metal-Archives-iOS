//
//  RequestStatistic.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 05/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

extension RequestHelper.HomePage {
    final class Statistic {
        private static let requestURLString = "https://www.metal-archives.com/index/ajax-stats"
        
        typealias FetchStatisticSuccessfullyCompletion = (_ response: String) -> Void
        typealias FetchStatisticErrorCompletion = (Error) -> Void
        
        private init () {}
        
        static func fetchStats(onSuccess: @escaping FetchStatisticSuccessfullyCompletion, onError: @escaping FetchStatisticErrorCompletion) {
            let requestURL = URL(string: requestURLString)!
            
            RequestHelper.shared.alamofireManager.request(requestURL).responseString { (response) in
                switch response.result {
                case .success:
                    if let responseString = response.value {
                        //Remove hyperlink at the end
                        let truncatedString = String(responseString.split(separator: ".")[0])
                        onSuccess(truncatedString)
                    } else {
                        assertionFailure("Error fetching statistic.")
                    }
                case .failure(let error):
                    onError(error)
                }
            }
        }
    }
}
