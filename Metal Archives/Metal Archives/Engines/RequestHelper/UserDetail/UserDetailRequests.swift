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
    static func fetchUserProfile(username: String, completion: @escaping (_ myProfile: UserProfile?, _ error: MAParsingError?) -> Void) {
        let requestURL = URL(string: "https://www.metal-archives.com/users/\(username.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed) ?? "")")!
        RequestHelper.shared.alamofireManager.request(requestURL).responseData { (response) in
            switch response.result {
            case .success:
                if let data = response.data {
                    if let myProfile = UserProfile(from: data, username: username) {
                        completion(myProfile, nil)
                    } else {
                        completion(nil, MAParsingError.badStructure(objectType: "UserProfile"))
                    }
                    
                } else {
                    completion(nil, MAParsingError.noData)
                }
            
            case .failure(let error):
                completion(nil, MAParsingError.unknown(description: error.localizedDescription))
            }
        }
    }
}
