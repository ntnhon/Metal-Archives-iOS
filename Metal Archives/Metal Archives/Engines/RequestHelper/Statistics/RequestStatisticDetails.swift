//
//  RequestStatisticDetails.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

extension RequestHelper {
    final class StatisticDetail {
        typealias FetchStatisticDetailOnSuccess = (_ statistic: Statistic) -> Void
        typealias FetchStatisticDetailOnError = (Error) -> Void
        
        static func fetchStatisticDetails(onSuccess: @escaping FetchStatisticDetailOnSuccess, onError: @escaping FetchStatisticDetailOnError) {
            let urlString = "https://www.metal-archives.com/stats"
            let requestURL = URL(string: urlString)!
            
            RequestHelper.shared.alamofireManager.request(requestURL).responseData { (response) in
                switch response.result {
                case .success:
                    if let data = response.data, let statistic = Statistic.init(fromData: data)  {
                        onSuccess(statistic)
                    } else {
                        let error = MAParsingError.badStructure(objectType: "Statistic")
                        onError(error)
                    }
                    
                case .failure(let error): onError(error)
                }
            }
        }
    }
}
