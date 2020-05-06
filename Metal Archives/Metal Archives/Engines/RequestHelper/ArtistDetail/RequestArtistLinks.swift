//
//  RequestArtistLinks.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 18/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import Kanna

extension RequestHelper.ArtistDetail {
    typealias FetchArtistLinksOnSuccess = (_ links: [RelatedLink]?) -> Void
    typealias FetchArtistLinksOnError = (Error) -> Void
    
    static func fetchArtistLinks(id: String, onSuccess: @escaping FetchArtistLinksOnSuccess, onError: @escaping FetchArtistLinksOnError) {
        let requestURLString = "https://www.metal-archives.com/link/ajax-list/type/person/id/" + id
        let requestURL = URL(string: requestURLString)!
        
        RequestHelper.shared.alamofireManager.request(requestURL).responseData { (response) in
            switch response.result {
            case .success:
                if let data = response.data {
                    let links = [RelatedLink].from(data: data)
                    onSuccess(links)
                }
                
            case .failure(let error): onError(error)
            }
        }
    }
}
