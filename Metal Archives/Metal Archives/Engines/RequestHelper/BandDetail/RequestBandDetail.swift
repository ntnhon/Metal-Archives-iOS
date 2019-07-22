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
            guard let requestURL = URL(string: urlString) else {
                onError(MANetworkingError.badURL(urlString))
                return
            }
            
            RequestHelper.shared.alamofireManager.request(requestURL).responseData { (response) in
                switch response.result {
                case .success:
                    if let data = response.data, let band = Band.init(fromData: data) {
                        onSuccess(band)
                    } else {
                        let error = MAParsingError.badStructure(objectType: "Band")
                        onError(error)
                    }
                    
                case .failure(let error): onError(error)
                }
            }
        }
    }
}
