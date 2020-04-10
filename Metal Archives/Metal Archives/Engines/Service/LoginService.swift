//
//  LoginService.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 09/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import Alamofire

final class LoginService {
    static private(set) var isLoggedIn = false
    
    static func login(username: String, password: String, completion: @escaping (_ error: MALoginError?) -> Void) {
        isLoggedIn = false
        
        // First make a dummy post to generate PHPSESSID
        RequestHelper.shared.alamofireManager.request(URL(string: "https://www.metal-archives.com")!, method: .post, parameters: nil, encoding: URLEncoding.default, headers: nil).response { (_) in
            
            // PHPSESSID is generated and saved
            let parameters: HTTPHeaders = ["loginUsername": username, "loginPassword": password, "origin": "/"]
            let url = URL(string: "https://www.metal-archives.com/authentication/login")!
            RequestHelper.shared.alamofireManager.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: nil).responseString { (response) in
                
                guard let response = response.response else {
                    isLoggedIn = false
                    completion(MALoginError.emptyResponse)
                    return
                }
                
                switch response.statusCode {
                case 200:
                    isLoggedIn = true
                    completion(nil)
                    
                case 403: completion(MALoginError.incorrectCredential)
                    
                default:
                    isLoggedIn = false
                    completion(MALoginError.unknown(description: "code \(response.statusCode)"))
                }
            }
            
        }
    }
    
    static func logOut() {
        isLoggedIn = false
    }
}

extension LoginService {
    static func fetchMyProfile(username: String, completion: @escaping (_ myProfile: MyProfile?, _ error: MALoginError?) -> Void) {
        let requestURL = URL(string: "https://www.metal-archives.com/users/\(username)")!
        RequestHelper.shared.alamofireManager.request(requestURL).responseData { (response) in
            switch response.result {
            case .success:
                if let data = response.data {
                    if let myProfile = MyProfile(from: data, username: username) {
                        completion(myProfile, nil)
                    } else {
                        completion(nil, MALoginError.failedToParseMyProfile)
                    }
                    
                } else {
                    completion(nil, MALoginError.emptyResponse)
                }
            
            case .failure(let error):
                completion(nil, MALoginError.unknown(description: error.localizedDescription))
            }
        }
    }
}
