//
//  HomepageRequests.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 06/05/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

extension RequestHelper {
    final class Homepage {}
}

extension RequestHelper.Homepage {
    static func fetchStats(completion: @escaping (Result<HomepageStatistic, MAError>) -> Void) {
        let requestUrlString = "https://www.metal-archives.com/index/ajax-stats"
        guard let requestUrl = URL(string: requestUrlString) else {
            completion(.failure(.networking(error: .badURL(requestUrlString))))
            return
        }
        
        RequestHelper.shared.alamofireManager.request(requestUrl).responseString { response in
            switch response.result {
            case .success(let string):
                if let homepageStatistic = HomepageStatistic(fromRawStatString: string) {
                    completion(.success(homepageStatistic))
                } else {
                    completion(.failure(.parsing(error: .badStructure(anyObject: HomepageStatistic.self))))
                }
                
            case .failure(let error):
                completion(.failure(.unknown(description: error.localizedDescription)))
            }
        }
    }
}
