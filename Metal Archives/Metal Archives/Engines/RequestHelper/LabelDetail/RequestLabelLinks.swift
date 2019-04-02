//
//  RequestLabelLinks.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 25/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import Kanna

extension RequestHelper.LabelDetail {
    typealias FetchLabelLinksOnSuccess = ([RelatedLink]?) -> Void
    typealias FetchLabelLinksOnError = (Error) -> Void
    
    static func fetchLabelLinks(id: String, onSuccess: @escaping FetchLabelLinksOnSuccess, onError: @escaping FetchLabelLinksOnError) {
        let requestURLString = "https://www.metal-archives.com/link/ajax-list/type/label/id/" + id
        let requestURL = URL(string: requestURLString)!
        
        RequestHelper.shared.alamofireManager.request(requestURL).responseData { (response) in
            switch response.result {
            case .success:
                if let data = response.data {
                    let links = RequestHelper.extractLinks(data: data)
                    onSuccess(links)
                }
                
            case .failure(let error): onError(error)
            }
        }
    }
}
