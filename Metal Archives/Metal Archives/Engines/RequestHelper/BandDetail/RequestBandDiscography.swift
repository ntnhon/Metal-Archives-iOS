//
//  RequestBandDiscography.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 05/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

extension RequestHelper.BandDetail {
    typealias FetchDiscographyOnSuccess = (_ discography: Discography?) -> Void
    typealias FetchDiscographyOnError = (Error) -> Void
    
    static func fetchDiscography(bandID: String, onSuccess: @escaping FetchDiscographyOnSuccess, onError: @escaping FetchDiscographyOnError) {
        let requestURLString = "https://www.metal-archives.com/band/discography/id/<BAND_ID>/tab/all".replacingOccurrences(of: "<BAND_ID>", with: bandID)
        let requestURL = URL(string: requestURLString)!
        
        RequestHelper.shared.alamofireManager.request(requestURL).responseData { (response) in
            switch response.result {
            case .success:
                if let data = response.data {
                    let discography = Discography.init(data: data)
                    onSuccess(discography)
                }
                
            case .failure(let error): onError(error)
            }
        }
    }
}
