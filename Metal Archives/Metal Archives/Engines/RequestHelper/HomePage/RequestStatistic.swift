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
        
        private init () {}
        
        static func fetchStats(completionHandler: @escaping (() throws -> HomepageStatistic) -> Void) {
            guard let requestURL = URL(string: requestURLString) else {
                completionHandler { throw MANetworkingError.badURL(requestURLString) }
                return
            }
            
            RequestHelper.shared.alamofireManager.request(requestURL).responseString { (response) in
                switch response.result {
                case .success:
                    guard let responseString = response.value else {
                        completionHandler { throw MANetworkingError.badResponse(response) }
                        return
                    }
                    
                    do {
                        let homepageStatistic = try HomepageStatistic(fromRawStatString: responseString)
                        completionHandler { return homepageStatistic }
                    } catch {
                        completionHandler { throw error }
                    }
                    
                case .failure(let error):
                    completionHandler { throw error }
                }
            }
        }
    }
}
