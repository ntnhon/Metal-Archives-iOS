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
        let parameters: HTTPHeaders = ["loginUsername": username, "loginPassword": password, "origin": "/"]
        let url = URL(string: "https://www.metal-archives.com/authentication/login")!
        
        // First make a dummy post to generate PHPSESSID
        RequestHelper.shared.alamofireManager.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: nil).responseString { (_) in
            
            // PHPSESSID is generated and saved
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
