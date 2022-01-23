//
//  RequestService.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 07/05/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import Alamofire

final class RequestService {
    static let shared = RequestService()
    let alamofireSession:  Alamofire.Session = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.httpMaximumConnectionsPerHost = 10
        return Alamofire.Session(configuration: configuration)
    }()
    
    private init() {}
}
