
//
//  RequestReleaseDetail.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 05/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

extension RequestHelper {
    final class ReleaseDetail {
        typealias FetchReleaseOnSuccess = (_ release: Release) -> Void
        typealias FetchReleaseOnError = (Error) -> Void
        
        private init () {}
        
        static func fetchReleaseDetail(urlString: String, onSuccess: @escaping FetchReleaseOnSuccess, onError: @escaping FetchReleaseOnError) {
            let requestURL = URL(string: urlString)!
            
            RequestHelper.shared.alamofireManager.request(requestURL).responseData { (response) in
                switch response.result {
                case .success:
                    if let data = response.data, let release = Release(data: data) {
                        onSuccess(release)
                    } else {
                        let error = MAParsingError.badStructure(objectType: "Release")
                        onError(error)
                    }
                    
                case .failure(let error): onError(error)
                }
            }
        }
        
    }
}
