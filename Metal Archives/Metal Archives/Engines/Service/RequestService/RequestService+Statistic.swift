//
//  RequestService+Statistic.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 07/05/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

extension RequestService {
    final class Statistic {
        private init() {}
    }
}

extension RequestService.Statistic {
    static func fetchStatistic(completion: @escaping (Result<Statistic, MAError>) -> Void) {
        let requestUrlString = "https://www.metal-archives.com/stats"
        guard let requestUrl = URL(string: requestUrlString) else {
            completion(.failure(.networking(error: .badURL(requestUrlString))))
            return
        }
        
        RequestService.shared.alamofireSession.request(requestUrl).responseData { (response) in
            switch response.result {
            case .success(let data):
                if let statistic = Statistic.init(fromData: data)  {
                    completion(.success(statistic))
                } else {
                    completion(.failure(.parsing(error: .badStructure(anyObject: Statistic.self))))
                }
                
            case .failure(let error):
                completion(.failure(.alamofire(error: error)))
            }
        }
    }
    
    static func fetchTop100Bands(completion: @escaping (Result<Top100Bands, MAError>) -> Void) {
        let requestUrlString = "https://www.metal-archives.com/stats/bands"
        guard let requestUrl = URL(string: requestUrlString) else {
            completion(.failure(.networking(error: .badURL(requestUrlString))))
            return
        }
        
        RequestService.shared.alamofireSession.request(requestUrl).responseData { (response) in
            switch response.result {
            case .success(let data):
                if let top100Bands = Top100Bands.init(fromData: data) {
                    completion(.success(top100Bands))
                } else {
                    completion(.failure(.parsing(error: .badStructure(anyObject: Top100Bands.self))))
                }
                
            case .failure(let error):
                completion(.failure(.alamofire(error: error)))
            }
        }
    }
    
    static func fetchTop100Albums(completion: @escaping (Result<Top100Albums, MAError>) -> Void) {
        let requestUrlString = "https://www.metal-archives.com/stats/albums"
        guard let requestUrl = URL(string: requestUrlString) else {
            completion(.failure(.networking(error: .badURL(requestUrlString))))
            return
        }
        
        RequestService.shared.alamofireSession.request(requestUrl).responseData { (response) in
            switch response.result {
            case .success(let data):
                if let top100Albums = Top100Albums.init(fromData: data) {
                    completion(.success(top100Albums))
                } else {
                    completion(.failure(.parsing(error: .badStructure(anyObject: Top100Albums.self))))
                }
                
            case .failure(let error):
                completion(.failure(.alamofire(error: error)))
            }
        }
    }
}
