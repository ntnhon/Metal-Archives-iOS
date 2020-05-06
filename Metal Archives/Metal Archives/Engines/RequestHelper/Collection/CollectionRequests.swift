//
//  CollectionRequests.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 12/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import Alamofire

extension RequestHelper {
    final class Collection {}
}

extension RequestHelper.Collection {
    static func getVersionList(id: String, completion: @escaping (Result<[ReleaseVersion], MAError>) -> Void) {
        let requestUrlString = "https://www.metal-archives.com/release/version-json-list/parentId/\(id)"
        guard let requestUrl = URL(string: requestUrlString) else {
            completion(.failure(.networking(error: .badURL(requestUrlString))))
            return
        }
        
        RequestHelper.shared.alamofireManager.request(requestUrl).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let json = value as? [[String: String]] {
                    var releaseVersions: [ReleaseVersion] = []
                    json.forEach { (versionDetails) in
                        if let id = versionDetails["id"], let version = versionDetails["version"] {
                            releaseVersions.append(ReleaseVersion(id: id, version: version))
                        }
                    }
                    
                    if releaseVersions.count > 0 {
                        releaseVersions.insert(ReleaseVersion(id: "0", version: "Unspecified"), at: 0)
                        completion(.success(releaseVersions))
                    } else {
                        completion(.failure(.parsing(error: .badStructure(anyObject: ReleaseVersion.self))))
                    }
                    
                } else {
                    completion(.failure(.parsing(error: .badJsonSyntax(actualSyntax: value.self, expectedSyntax: [[String: String]].self))))
                }
                
            case .failure(let error):
                completion(.failure(.networking(error: .failedToFetch(anyObject: [ReleaseVersion].self, error: error))))
            }
        }
    }
    
    static func changeVersion(collection: MyCollection, release: ReleaseInCollection, versionId: String, completion: @escaping (_ isSuccessful: Bool) -> Void) {
        let requestURL = URL(string: "https://www.metal-archives.com/collection/save/tab/\(collection.urlParam)")!
        let parameters = ["versions[\(release.editId)]": versionId, "notes[\(release.editId)]": release.note ?? "","changes[\(release.editId)]": "1"]
        
        RequestHelper.shared.alamofireManager.request(requestURL, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: nil).response { (response) in
            if let statusCode = response.response?.statusCode, statusCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    static func updateNote(collection: MyCollection, release: ReleaseInCollection, newNote: String?, completion: @escaping (_ isSuccessful: Bool) -> Void) {
        let requestURL = URL(string: "https://www.metal-archives.com/collection/save/tab/\(collection.urlParam)")!
        let parameters = ["versions[\(release.editId)]": "", "notes[\(release.editId)]": newNote ?? "","changes[\(release.editId)]": "1"]
        
        RequestHelper.shared.alamofireManager.request(requestURL, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: nil).response { (response) in
            if let statusCode = response.response?.statusCode, statusCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    static func remove(release: ReleaseInCollection, from collection: MyCollection, completion: @escaping (_ isSuccessful: Bool) -> Void) {
        let requestURL = URL(string: "https://www.metal-archives.com/collection/save/tab/\(collection.urlParam)")!
        let parameters = ["notes[\(release.editId)]": "", "item[\(release.editId)]": "1", "changes[\(release.editId)]": "1", "choice": "delete"]
        
        RequestHelper.shared.alamofireManager.request(requestURL, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: nil).response { (response) in
            if let statusCode = response.response?.statusCode, statusCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    static func add(releaseId: String, to collection: MyCollection, completion: @escaping (_ isSuccessful: Bool) -> Void) {
        let requestURL = URL(string: "https://www.metal-archives.com/collection/add/json/1/id/\(releaseId)/type/\(collection.addOrRemoveParam)")!
        
        RequestHelper.shared.alamofireManager.request(requestURL).response { (response) in
            if let statusCode = response.response?.statusCode, statusCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    static func move(release: ReleaseInCollection, from fromCollection: MyCollection, to toCollection: MyCollection, completion: @escaping (_ isSuccessful: Bool) -> Void) {
        let requestURL = URL(string: "https://www.metal-archives.com/collection/save/tab/\(fromCollection.urlParam)")!
        let parameters = ["notes[\(release.editId)]": release.note ?? "", "item[\(release.editId)]": "1", "changes[\(release.editId)]": "1", "choice": toCollection.urlParam]
        
        RequestHelper.shared.alamofireManager.request(requestURL, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: nil).response { (response) in
            if let statusCode = response.response?.statusCode, statusCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}
