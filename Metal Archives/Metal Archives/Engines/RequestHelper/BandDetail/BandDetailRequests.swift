//
//  BandDetailRequests.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 06/05/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

extension RequestHelper {
    final class BandDetail {}
}

extension RequestHelper.BandDetail {
    static func fetchBandGeneralInfo(urlString: String, completion: @escaping (Result<Band, MAError>) -> Void) {
        guard let requestUrl = URL(string: urlString) else {
            completion(.failure(.networking(error: .badURL(urlString))))
            return
        }
        
        RequestHelper.shared.alamofireManager.request(requestUrl).responseData { response in
            switch response.result {
            case .success(let data):
                if let band = Band.init(fromData: data) {
                    completion(.success(band))
                } else {
                    completion(.failure(.parsing(error: .badStructure(anyObject: Band.self))))
                }
                
            case .failure(let error):
                completion(.failure(.unknown(description: error.localizedDescription)))
            }
        }
    }
    
    static func fetchReadMore(bandID: String, completion: @escaping (Result<String, MAError>) -> Void) {
        let requestUrlString = "https://www.metal-archives.com/band/read-more/id/" + bandID
        guard let requestUrl = URL(string: requestUrlString) else {
            completion(.failure(.networking(error: .badURL(requestUrlString))))
            return
        }
        
        RequestHelper.shared.alamofireManager.request(requestUrl).responseData { response in
            let defaultMessage = "No information added"
            switch response.result {
            case .success(let data):
                let readMoreString = String.htmlBodyString(data: data)
                completion(.success(readMoreString ?? defaultMessage))
                
            case .failure(let error):
                switch error {
                case .responseSerializationFailed(let reason):
                    switch reason {
                    case .inputDataNilOrZeroLength: completion(.success(defaultMessage))
                    default: completion(.failure(.unknown(description: error.localizedDescription)))
                    }
                default: completion(.failure(.unknown(description: error.localizedDescription)))
                }
            }
        }
    }
    
    static func fetchDiscography(bandID: String, completion: @escaping (Result<Discography?, MAError>) -> Void) {
        let requestUrlString = "https://www.metal-archives.com/band/discography/id/\(bandID)/tab/all"
        guard let requestUrl = URL(string: requestUrlString) else {
            completion(.failure(.networking(error: .badURL(requestUrlString))))
            return
        }
        
        RequestHelper.shared.alamofireManager.request(requestUrl).responseData { response in
            switch response.result {
            case .success(let data):
                let discography = Discography.init(data: data)
                completion(.success(discography))
                
            case .failure(let error):
                completion(.failure(.unknown(description: error.localizedDescription)))
            }
        }
    }
    
    static func fetchSimilarArtists(bandID: String, completion: @escaping (Result<[BandSimilar]?, MAError>) -> Void) {
        let requestUrlString = "https://www.metal-archives.com/band/ajax-recommendations/id/\(bandID)/showMoreSimilar/1"
        guard let requestUrl = URL(string: requestUrlString) else {
            completion(.failure(.networking(error: .badURL(requestUrlString))))
            return
        }
        
        RequestHelper.shared.alamofireManager.request(requestUrl).responseData { response in
            switch response.result {
            case .success(let data):
                let similarBands = [BandSimilar].from(data: data)
                completion(.success(similarBands))
                
            case .failure(let error):
                completion(.failure(.unknown(description: error.localizedDescription)))
            }
        }
    }
    
    static func fetchRelatedLinks(bandID: String, completion: @escaping (Result<[RelatedLink]?, MAError>) -> Void) {
        let requestUrlString = "https://www.metal-archives.com/link/ajax-list/type/band/id/" + bandID
        guard let requestUrl = URL(string: requestUrlString) else {
            completion(.failure(.networking(error: .badURL(requestUrlString))))
            return
        }
        
        RequestHelper.shared.alamofireManager.request(requestUrl).responseData { response in
            switch response.result {
            case .success(let data):
                let relatedLinks = [RelatedLink].from(data: data)
                completion(.success(relatedLinks))
                
            case .failure(let error):
                completion(.failure(.unknown(description: error.localizedDescription)))
            }
        }
    }
}
