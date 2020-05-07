//
//  RequestService+Deezer.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 07/05/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

extension RequestService {
    final class Deezer {
        private init() {}
    }
}

extension RequestService.Deezer {
    static func fetchDeezerAlbum(urlString: String, completion: @escaping (Result<DeezerData<DeezerAlbum>, MAError>) -> Void) {
        fetchGenericJsonData(urlString: urlString, completetion: completion)
    }
    
    static func fetchDeezerTrack(urlString: String, completion: @escaping (Result<DeezerData<DeezerTrack>, MAError>) -> Void) {
        fetchGenericJsonData(urlString: urlString, completetion: completion)
    }

    static func fetchDeezerArtist(urlString: String, completion: @escaping (Result<DeezerData<DeezerArtist>, MAError>) -> Void) {
        fetchGenericJsonData(urlString: urlString, completetion: completion)
    }
    
    fileprivate static func fetchGenericJsonData<T: Decodable>(urlString: String, completetion: @escaping (Result<T, MAError>) -> Void) {
        guard let requestUrl = URL(string: urlString) else {
            completetion(.failure(.networking(error: .badURL(urlString))))
            return
        }
        
        RequestService.shared.alamofireManager.request(requestUrl).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let objects = try JSONDecoder().decode(T.self, from: data)
                    completetion(.success(objects))
                } catch {
                    completetion(.failure(.unknown(description: error.localizedDescription)))
                }
                
            case .failure(let error):
                completetion(.failure(.alamofire(error: error)))
            }
        }
    }
}
