//
//  RequestBandReadMore.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 05/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import Kanna

extension RequestHelper.BandDetail {
    typealias FetchReadMoreOnSuccess = (_ readMore: String) -> Void
    typealias FetchReadMoreOnError = (Error) -> Void
    
    static func fetchReadMore(bandID: String, onSuccess: @escaping FetchReadMoreOnSuccess, onError: @escaping FetchReadMoreOnError) {
        let requestURLString = "https://www.metal-archives.com/band/read-more/id/" + bandID
        let requestURL = URL(string: requestURLString)!
        
        RequestHelper.shared.alamofireManager.request(requestURL).responseData { (response) in
            switch response.result {
            case .success:
                if let data = response.data {
                    let readMoreString = RequestHelper.BandDetail.extractReadMore(data: data)
                    onSuccess(readMoreString)
                }
                
            case .failure(let error): onError(error)
            }
        }
    }
    
    private static func extractReadMore(data: Data) -> String {
        let noReadMoreString = "No information added"
        guard let htmlString = String(data: data, encoding: String.Encoding.utf8) else {
            return noReadMoreString
        }
        
        if let doc = try? Kanna.HTML(html: htmlString, encoding: String.Encoding.utf8) {
            for tag in doc.css("html") {
                let bodyTag = tag.at_css("body")
                if let readMoreString =  bodyTag?.text {
                    return readMoreString
                }
                
                return noReadMoreString
            }
            
        }
        
        return noReadMoreString
    }
}
