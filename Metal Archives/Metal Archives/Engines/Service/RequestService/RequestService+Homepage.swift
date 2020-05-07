//
//  RequestService+Homepage.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 07/05/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

extension RequestService {
    final class Homepage {
        private init() {}
    }
}

extension RequestService.Homepage {
    static func fetchStatistic(completion: @escaping (Result<HomepageStatistic, MAError>) -> Void) {
        let requestUrlString = "https://www.metal-archives.com/index/ajax-stats"
        guard let requestUrl = URL(string: requestUrlString) else {
            completion(.failure(.networking(error: .badURL(requestUrlString))))
            return
        }
        
        RequestService.shared.alamofireSession.request(requestUrl).responseString { response in
            switch response.result {
            case .success(let string):
                if let homepageStatistic = HomepageStatistic(fromRawStatString: string) {
                    completion(.success(homepageStatistic))
                } else {
                    completion(.failure(.parsing(error: .badStructure(anyObject: HomepageStatistic.self))))
                }
                
            case .failure(let error):
                completion(.failure(.alamofire(error: error)))
            }
        }
    }
}
