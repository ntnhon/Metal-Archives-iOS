//
//  RequestBandRelatedLinks.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 05/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import Kanna

extension RequestHelper.BandDetail {
    typealias FetchRelatedLinksOnSuccess = (_ relatedLinks: [RelatedLink]?) -> Void
    typealias FetchRelatedLinksOnError = (Error) -> Void
    
    static func fetchRelatedLinks(bandID: String, onSuccess: @escaping FetchRelatedLinksOnSuccess, onError: @escaping FetchRelatedLinksOnError) {
        let requestURLString = "https://www.metal-archives.com/link/ajax-list/type/band/id/" + bandID
        let requestURL = URL(string: requestURLString)!
        
        RequestHelper.shared.alamofireManager.request(requestURL).responseData { (response) in
            switch response.result {
            case .success:
                if let data = response.data {
                    let relatedLinks = RequestHelper.extractLinks(data: data)
                    onSuccess(relatedLinks)
                }
                
            case .failure(let error): onError(error)
            }
        }
    }
}
