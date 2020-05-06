//
//  RequestArtistBiography.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 18/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import Kanna

extension RequestHelper.ArtistDetail {
    typealias FetchArtistBiographyOnSuccess = (_ biography: String?) -> Void
    typealias FetchArtistBiographyOnError = (Error) -> Void
    
    static func fetchArtistBiography(id: String, onSuccess: @escaping FetchArtistBiographyOnSuccess, onError: @escaping FetchArtistBiographyOnError) {
        let requestURLString = "https://www.metal-archives.com/artist/read-more/id/" + id
        let requestURL = URL(string: requestURLString)!
        
        RequestHelper.shared.alamofireManager.request(requestURL).responseData { (response) in
            switch response.result {
            case .success:
                if let data = response.data {
                    let biographyString = RequestHelper.ArtistDetail.extractBiography(data: data)
                    onSuccess(biographyString)
                }
                
            case .failure(let error):
                switch error {
                case .responseSerializationFailed(let reason):
                    switch reason {
                    case .inputDataNilOrZeroLength: onSuccess(nil)
                    default: onError(error)
                    }
                default: onError(error)
                }
            }
        }
        
    }
    
    private static func extractBiography(data: Data) -> String? {
        guard let htmlString = String(data: data, encoding: String.Encoding.utf8) else {
            return nil
        }
        
        if let doc = try? Kanna.HTML(html: htmlString, encoding: String.Encoding.utf8) {
            for tag in doc.css("html") {
                let bodyTag = tag.at_css("body")
                if let biographyString =  bodyTag?.text {
                    return biographyString
                }
                
                return nil
            }
            
        }
        
        return nil
    }
}
