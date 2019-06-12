//
//  RequestArtistDetail.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 18/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

extension RequestHelper {
    final class ArtistDetail {
        typealias FetchArtistDetailOnSuccess = (_ artist: Artist) -> Void
        typealias FetchArtistDetailOnError = (Error) -> Void
        
        static func fetchArtistDetail(urlString: String, onSuccess: @escaping FetchArtistDetailOnSuccess, onError: @escaping FetchArtistDetailOnError) {
            let requestURL = URL(string: urlString)!
            
            RequestHelper.shared.alamofireManager.request(requestURL).responseData { (response) in
                switch response.result {
                case .success:
                    if let data = response.data, let artist = Artist.init(fromData: data, urlString: urlString)  {
                        onSuccess(artist)
                    } else {
                        let error = MAParsingError.badStructure(objectType: "Artist")
                        onError(error)
                    }
                    
                case .failure(let error): onError(error)
                }
            }
        }
    }
}


