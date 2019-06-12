//
//  RequestLabelDetail.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 24/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

extension RequestHelper {
    final class LabelDetail {
        typealias FetchLabelDetailOnSuccess = (_ label: Label) -> Void
        typealias FetchLabelDetailOnError = (Error) -> Void
        
        static func fetchLabelDetail(urlString: String, onSuccess: @escaping FetchLabelDetailOnSuccess, onError: @escaping FetchLabelDetailOnError) {
            let requestURL = URL(string: urlString)!
            
            RequestHelper.shared.alamofireManager.request(requestURL).responseData { (response) in
                switch response.result {
                case .success:
                    if let data = response.data, let label = Label.init(fromData: data, urlString: urlString) {
                        onSuccess(label)
                    } else {
                        let error = MAParsingError.badStructure(objectType: "Label")
                        onError(error)
                    }
                    
                case .failure(let error): onError(error)
                }
            }
        }
    }
}
