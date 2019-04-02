//
//  RequestLyric.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 18/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

extension RequestHelper.ReleaseDetail {
    typealias FetchLyricOnSuccess = (_ lyric: String) -> Void
    typealias FetchLyricOnError = (Error) -> Void
    
    static func fetchLyric(lyricID: String, onSuccess: @escaping FetchLyricOnSuccess, onError: @escaping FetchLyricOnError) {
        let requestURLString = "https://www.metal-archives.com/release/ajax-view-lyrics/id/" + lyricID
        
        let requestURL = URL(string: requestURLString)!
        RequestHelper.shared.alamofireManager.request(requestURL).responseString { (response) in

            if let lyric = response.value {
                onSuccess(lyric)
            } else {
                onError(NSError(domain: "", code: 0, userInfo: nil))
            }
        }
        }
}
