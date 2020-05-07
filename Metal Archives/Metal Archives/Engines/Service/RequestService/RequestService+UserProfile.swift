//
//  RequestService+UserProfile.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 07/05/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

extension RequestService {
    final class UserProfile {
        private init() {}
    }
}

extension RequestService.UserProfile {
    static func fetchWithUsername(_ username: String, completion: @escaping (Result<UserProfile, MAError>) -> Void) {
        fetchWithUrlString("https://www.metal-archives.com/users/\(username.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed) ?? "")", completion: completion)
    }
    
    static func fetchWithUrlString(_ urlString: String, completion: @escaping (Result<UserProfile, MAError>) -> Void) {
        guard let requestURL = URL(string: urlString) else {
            completion(.failure(.networking(error: .badURL(urlString))))
            return
        }
        
        RequestService.shared.alamofireSession.request(requestURL).responseData { (response) in
            switch response.result {
            case .success(let data):
                if let myProfile = UserProfile(from: data) {
                    completion(.success(myProfile))
                } else {
                    completion(.failure(.parsing(error: .badStructure(anyObject: UserProfile.self))))
                }
            
            case .failure(let error):
                completion(.failure(.unknown(description: error.localizedDescription)))
            }
        }
    }
}
