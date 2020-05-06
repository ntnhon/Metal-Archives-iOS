//
//  UserDetailRequests.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 14/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import Alamofire

extension RequestHelper {
    final class UserDetail {}
}

extension RequestHelper.UserDetail {
    static func fetchUserProfile(username: String, completion: @escaping (Result<UserProfile, MAError>) -> Void) {
        fetchUserProfile(urlString: "https://www.metal-archives.com/users/\(username.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed) ?? "")", completion: completion)
    }
    
    static func fetchUserProfile(urlString: String, completion: @escaping (Result<UserProfile, MAError>) -> Void) {
        guard let requestURL = URL(string: urlString) else {
            completion(.failure(.networking(error: .badURL(urlString))))
            return
        }
        
        RequestHelper.shared.alamofireManager.request(requestURL).responseData { (response) in
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
