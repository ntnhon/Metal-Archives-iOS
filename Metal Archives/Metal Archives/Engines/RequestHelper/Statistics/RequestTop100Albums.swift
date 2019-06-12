//
//  RequestTop100Albums.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

extension RequestHelper.StatisticDetail {
    typealias FetchTop100AlbumsOnSuccess = (_ top100Albums: Top100Albums) -> Void
    typealias FetchTop100AlbumsOnError = (Error) -> Void
    
    static func fetchTop100Albums(onSuccess: @escaping FetchTop100AlbumsOnSuccess, onError: @escaping FetchTop100AlbumsOnError) {
        let urlString = "https://www.metal-archives.com/stats/albums"
        let requestURL = URL(string: urlString)!
        
        RequestHelper.shared.alamofireManager.request(requestURL).responseData { (response) in
            switch response.result {
            case .success:
                if let data = response.data, let top100Albums = Top100Albums.init(fromData: data) {
                    onSuccess(top100Albums)
                } else {
                    let error = MAParsingError.badStructure(objectType: "Top 100 Albums")
                    onError(error)
                }
                
            case .failure(let error): onError(error)
            }
        }
    }
}
