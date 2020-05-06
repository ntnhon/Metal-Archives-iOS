//
//  RequestHelper.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 15/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import Alamofire

final class RequestHelper {
    private(set) static var shared = RequestHelper()
    private(set) var alamofireManager:  Alamofire.Session = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        configuration.httpMaximumConnectionsPerHost = 10
        return Alamofire.Session(configuration: configuration)
    }()
    
    private init() {}
}

extension RequestHelper {
    final class HomePage {
        private init () {}
    }
}
