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
        
        let parameters: HTTPHeaders = ["loginUsername": username, "loginPassword": password]
        
        RequestHelper.shared.alamofireManager.request(URL(string: "https://www.metal-archives.com/authentication/login")!, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: nil).responseString { (response) in
            
            guard let response = response.response else {
                isLoggedIn = false
                completion(MALoginError.emptyResponse)
                return
            }
            
            switch response.statusCode {
            case 200:
                let cookies = HTTPCookieStorage.shared.cookies
                cookies?.forEach({ (cookie) in
                    switch cookie.name {
                    case "__cfduid": setCfduidCookie(cookie)
                    case "PHPSESSID": setPhpsessidCookie(cookie)
                    default: break
                    }
                })
                isLoggedIn = true
                completion(nil)
                
            case 403: completion(MALoginError.incorrectCredential)
                
            default:
                isLoggedIn = false
                completion(MALoginError.unknown(description: "code \(response.statusCode)"))
            }
        }
    }
    
    static func logOut() {
        isLoggedIn = false
    }
    
    private static func setCfduidCookie(_ cookie: HTTPCookie) {
        let cookieProps = [
            HTTPCookiePropertyKey.domain: ".metal-archives.com",
            HTTPCookiePropertyKey.path: "/",
            HTTPCookiePropertyKey.name: "__cfduid",
            HTTPCookiePropertyKey.value: cookie.value
        ]
        
        if let maCookie = HTTPCookie(properties: cookieProps) {
            RequestHelper.shared.alamofireManager.session.configuration.httpCookieStorage?.setCookie(maCookie)
        }
    }
    
    private static func setPhpsessidCookie(_ cookie: HTTPCookie) {
        let cookieProps = [
            HTTPCookiePropertyKey.domain: "www.metal-archives.com",
            HTTPCookiePropertyKey.path: "/",
            HTTPCookiePropertyKey.name: "PHPSESSID",
            HTTPCookiePropertyKey.value: cookie.value
        ]
        
        if let maCookie = HTTPCookie(properties: cookieProps) {
            RequestHelper.shared.alamofireManager.session.configuration.httpCookieStorage?.setCookie(maCookie)
        }
    }
}
