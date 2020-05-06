//
//  ReleaseDetailRequests.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 06/05/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
extension RequestHelper {
    final class ReleaseDetail {}
}
extension RequestHelper.ReleaseDetail {
    
    static func fetchReleaseDetail(urlString: String, completion: @escaping (Result<Release, MAError>) -> Void) {
        guard let requestUrl = URL(string: urlString) else {
            completion(.failure(.networking(error: .badURL(urlString))))
            return
        }
        
        RequestHelper.shared.alamofireManager.request(requestUrl).responseData { response in
            switch response.result {
            case .success(let data):
                if let release = Release(data: data) {
                    completion(.success(release))
                } else {
                    completion(.failure(.parsing(error: .badStructure(anyObject: Release.self))))
                }
                
            case .failure(let error):
                completion(.failure(.unknown(description: error.localizedDescription)))
            }
        }
    }
    
    static func fetchOtherVersion(releaseID: String, completion: @escaping (Result<[ReleaseOtherVersion], MAError>) -> Void) {
        let requestUrlString = "http://www.metal-archives.com/release/ajax-versions/current/\(releaseID)/parent/\(releaseID)"
        guard let requestUrl = URL(string: requestUrlString) else {
            completion(.failure(.networking(error: .badURL(requestUrlString))))
            return
        }
        
        RequestHelper.shared.alamofireManager.request(requestUrl).responseData { response in
            switch response.result {
            case .success(let data):
                let otherVersions = [ReleaseOtherVersion].from(data: data)
                completion(.success(otherVersions))
                
            case .failure(let error):
                completion(.failure(.unknown(description: error.localizedDescription)))
            }
        }
    }
    
    static func fetchLyric(lyricID: String, completion: @escaping (Result<String, MAError>) -> Void) {
        let requestUrlString = "https://www.metal-archives.com/release/ajax-view-lyrics/id/" + lyricID
        guard let requestUrl = URL(string: requestUrlString) else {
            completion(.failure(.networking(error: .badURL(requestUrlString))))
            return
        }
        
        RequestHelper.shared.alamofireManager.request(requestUrl).responseString { response in
            switch response.result {
            case .success(let lyric): completion(.success(lyric))
            case .failure(let error): completion(.failure(.unknown(description: error.localizedDescription)))
            }
        }
    }
}
