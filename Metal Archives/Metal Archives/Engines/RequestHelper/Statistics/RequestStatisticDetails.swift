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
        static func fetchStatisticDetails(completion: @escaping (Result<Statistic, MAError>) -> Void) {
            let requestUrlString = "https://www.metal-archives.com/stats"
            guard let requestUrl = URL(string: requestUrlString) else {
                completion(.failure(.networking(error: .badURL(requestUrlString))))
                return
            }
            
            RequestHelper.shared.alamofireManager.request(requestUrl).responseData { (response) in
                switch response.result {
                case .success(let data):
                    if let statistic = Statistic.init(fromData: data)  {
                        completion(.success(statistic))
                    } else {
                        completion(.failure(.parsing(error: .badStructure(anyObject: Statistic.self))))
                    }
                    
                case .failure(let error):
                    completion(.failure(.unknown(description: error.localizedDescription)))
                }
            }
        }
    }
}
