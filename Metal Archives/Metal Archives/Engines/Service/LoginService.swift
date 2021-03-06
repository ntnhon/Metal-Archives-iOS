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
    
    static func login(username: String, password: String, completion: @escaping (Result<Any?, MAError>) -> Void) {
        isLoggedIn = false
        let parameters = ["loginUsername": username, "loginPassword": password, "origin": "/"]
        let requestUrlString = "https://www.metal-archives.com/authentication/login"
        guard let url = URL(string: requestUrlString) else {
            completion(.failure(.networking(error: .badURL(requestUrlString))))
            return
        }
        
        // First make a dummy post to generate PHPSESSID
        RequestService.shared.alamofireSession.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: nil).responseString { (_) in
            
            // PHPSESSID is generated and saved
            RequestService.shared.alamofireSession.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: nil).responseString { (response) in
                
                guard let response = response.response else {
                    isLoggedIn = false
                    completion(.failure(.login(error: .emptyResponse)))
                    return
                }
                
                switch response.statusCode {
                case 200:
                    isLoggedIn = true
                    completion(.success(nil))
                    
                case 403: completion(.failure(.login(error: .incorrectCredential)))
                    
                default:
                    isLoggedIn = false
                    completion(.failure(.unknownErrorWithStatusCode(statusCode: response.statusCode)))
                }
            }
            
        }
    }
    
    static func logOut() {
        isLoggedIn = false
    }
}
