//
//  RequestBandDetail.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 05/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

extension RequestHelper {
    final class BandDetail {
        
        typealias FetchBandDetailOnSuccess = (_ response: Band) -> Void
        typealias FetchBandDetailOnError = (Error) -> Void
        
        private init () {}
        
        static func fetchBandDetail(urlString: String, onSuccess: @escaping FetchBandDetailOnSuccess, onError: @escaping FetchBandDetailOnError) {
            let requestURL = URL(string: urlString)!
            
            RequestHelper.shared.alamofireManager.request(requestURL).responseData { (response) in
                switch response.result {
                case .success:
                    if let data = response.data {
                        if let band = Band.init(fromData: data) {
                            onSuccess(band)
                        } else {
                            #warning("Handle error")
                            assertionFailure("Error parsing band's detail")
                        }
                    } else {
                        #warning("Handle error")
                        assertionFailure("Error loading band's detail")
                    }
                    
                case .failure(let error): onError(error)
                }
            }
        }
    }
}
