//
//  RequestService+Release.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 07/05/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

extension RequestService {
    final class Release {
        private init() {}
    }
}

// MARK: - Exposed functions
extension RequestService.Release {
    static func fetch(urlString: String, completion: @escaping (Result<Release, MAError>) -> Void) {
        fetchGeneralInfo(urlString: urlString) { result in
            switch result {
            case .success(let release):
                fetchOtherVersions(releaseId: release.id) { result in
                    switch result {
                    case .success(let otherVersions):
                        release.setOtherVersions(otherVersions)
                        completion(.success(release))
                        
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    static func fetchLyric(lyricId: String, completion: @escaping (Result<String, MAError>) -> Void) {
        let requestUrlString = "https://www.metal-archives.com/release/ajax-view-lyrics/id/" + lyricId
        guard let requestUrl = URL(string: requestUrlString) else {
            completion(.failure(.networking(error: .badURL(requestUrlString))))
            return
        }
        
        RequestService.shared.alamofireSession.request(requestUrl).responseString { response in
            switch response.result {
            case .success(let lyric): completion(.success(lyric))
            case .failure(let error): completion(.failure(.alamofire(error: error)))
            }
        }
    }
}

// MARK: - Private fetch detail functions
extension RequestService.Release {
    fileprivate static func fetchGeneralInfo(urlString: String, completion: @escaping (Result<Release, MAError>) -> Void) {
        guard let requestUrl = URL(string: urlString) else {
            completion(.failure(.networking(error: .badURL(urlString))))
            return
        }
        
        RequestService.shared.alamofireSession.request(requestUrl).responseData { response in
            switch response.result {
            case .success(let data):
                if let release = Release(data: data) {
                    completion(.success(release))
                } else {
                    completion(.failure(.parsing(error: .badStructure(anyObject: Release.self))))
                }
                
            case .failure(let error):
                completion(.failure(.alamofire(error: error)))
            }
        }
    }
    
    fileprivate static func fetchOtherVersions(releaseId: String, completion: @escaping (Result<[ReleaseOtherVersion], MAError>) -> Void) {
        let requestUrlString = "http://www.metal-archives.com/release/ajax-versions/current/\(releaseId)/parent/\(releaseId)"
        guard let requestUrl = URL(string: requestUrlString) else {
            completion(.failure(.networking(error: .badURL(requestUrlString))))
            return
        }
        
        RequestService.shared.alamofireSession.request(requestUrl).responseData { response in
            switch response.result {
            case .success(let data):
                let otherVersions = [ReleaseOtherVersion].from(data: data)
                completion(.success(otherVersions))
                
            case .failure(let error):
                completion(.failure(.alamofire(error: error)))
            }
        }
    }
}
