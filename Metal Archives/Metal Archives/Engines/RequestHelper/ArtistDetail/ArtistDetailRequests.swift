//
//  ArtistDetailRequests.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 06/05/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

extension RequestHelper {
    final class ArtistDetail {}
}

extension RequestHelper.ArtistDetail {
    
    static func fetchArtistGeneralInfo(urlString: String, completion: @escaping (Result<Artist, MAError>) -> Void) {
        guard let requestUrl = URL(string: urlString) else {
            completion(.failure(.networking(error: .badURL(urlString))))
            return
        }
        
        RequestHelper.shared.alamofireManager.request(requestUrl).responseData { response in
            switch response.result {
            case .success(let data):
                if let artist = Artist(fromData: data, urlString: urlString)  {
                    completion(.success(artist))
                } else {
                    completion(.failure(.parsing(error: .badStructure(anyObject: Artist.self))))
                }
                
            case .failure(let error):
                completion(.failure(.unknown(description: error.localizedDescription)))
            }
        }
    }
    
    static func fetchArtistBiography(id: String, completion: @escaping (Result<String?, MAError>) -> Void) {
        let requestUrlString = "https://www.metal-archives.com/artist/read-more/id/" + id
        guard let requestUrl = URL(string: requestUrlString) else {
            completion(.failure(.networking(error: .badURL(requestUrlString))))
            return
        }
        
        RequestHelper.shared.alamofireManager.request(requestUrl).responseData { (response) in
            switch response.result {
            case .success(let data):
                let biography = String.htmlBodyString(data: data)
                completion(.success(biography))
                
            case .failure(let error):
                switch error {
                case .responseSerializationFailed(let reason):
                    switch reason {
                    case .inputDataNilOrZeroLength:
                        completion(.success(nil))
                        
                    default:
                        completion(.failure(.unknown(description: error.localizedDescription)))
                    }
                    
                default:
                    completion(.failure(.unknown(description: error.localizedDescription)))
                }
            }
        }
    }
    
    static func fetchArtistTrivia(id: String, completion: @escaping (Result<String?, MAError>) -> Void) {
        let requestUrlString = "https://www.metal-archives.com/artist/read-more/id/\(id)/field/trivia"
        guard let requestUrl = URL(string: requestUrlString) else {
            completion(.failure(.networking(error: .badURL(requestUrlString))))
            return
        }
        
        RequestHelper.shared.alamofireManager.request(requestUrl).responseData { response in
            switch response.result {
            case .success(let data):
                let triviaString = String.htmlBodyString(data: data)
                completion(.success(triviaString))
                
            case .failure(let error):
                switch error {
                case .responseSerializationFailed(let reason):
                    switch reason {
                    case .inputDataNilOrZeroLength:
                        completion(.success(nil))
                        
                    default:
                        completion(.failure(.unknown(description: error.localizedDescription)))
                    }
                    
                default:
                    completion(.failure(.unknown(description: error.localizedDescription)))
                }
            }
        }
    }
    
    static func fetchArtistLinks(id: String, completion: @escaping (Result<[RelatedLink]?, MAError>) -> Void) {
        let requestUrlString = "https://www.metal-archives.com/link/ajax-list/type/person/id/" + id
        guard let requestUrl = URL(string: requestUrlString) else {
            completion(.failure(.networking(error: .badURL(requestUrlString))))
            return
        }
        
        RequestHelper.shared.alamofireManager.request(requestUrl).responseData { response in
            switch response.result {
            case .success(let data):
                let links = [RelatedLink].from(data: data)
                completion(.success(links))

            case .failure(let error):
                completion(.failure(.unknown(description: error.localizedDescription)))
            }
        }
    }
}
