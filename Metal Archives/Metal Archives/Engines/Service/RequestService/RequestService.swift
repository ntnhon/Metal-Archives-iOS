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
    private static var shared = RequestService()
    private var alamofireManager:  Alamofire.Session = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        configuration.httpMaximumConnectionsPerHost = 10
        return Alamofire.Session(configuration: configuration)
    }()
    
    private init() {}
}
