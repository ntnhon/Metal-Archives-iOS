//
//  Service.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 21/07/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class Service {
    static let shared = Service()

    func fetchDeezerArtist(urlString: String, completion: @escaping (DeezerData<DeezerArtist>?, Error?) -> Void) {
        fetchGenericJsonData(urlString: urlString, completetion: completion)
    }
    
    func fetchGenericJsonData<T: Decodable>(urlString: String, completetion: @escaping (T?, Error?) -> Void) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completetion(nil, error)
            }
            
            do {
                let objects = try JSONDecoder().decode(T.self, from: data!)
                completetion(objects, nil)
            } catch {
                completetion(nil, error)
            }
        }.resume()
    }
}
