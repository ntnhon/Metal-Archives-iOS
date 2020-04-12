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
    static func getVersionList(id: String, completion: @escaping (_ releaseVersions: [ReleaseVersion]?) -> Void) {
        let requestURL = URL(string: "https://www.metal-archives.com/release/version-json-list/parentId/\(id)")!
        
        RequestHelper.shared.alamofireManager.request(requestURL).responseJSON { (response) in
            if let json = response.result.value as? [[String: String]] {
                var releaseVersions: [ReleaseVersion] = []
                json.forEach { (versionDetails) in
                    if let id = versionDetails["id"], let version = versionDetails["version"] {
                        releaseVersions.append(ReleaseVersion(id: id, version: version))
                    }
                }
                
                if releaseVersions.count > 0 {
                    releaseVersions.insert(ReleaseVersion(id: "0", version: "Unspecified"), at: 0)
                    completion(releaseVersions)
                } else {
                    completion(nil)
                }
                
            } else {
                completion(nil)
            }
        }
    }
    
    static func changeVersion(collection: MyCollection, release: ReleaseInCollection, versionId: String, completion: @escaping (_ isSuccessful: Bool) -> Void) {
        let requestURL = URL(string: "https://www.metal-archives.com/collection/save/tab/\(collection.urlParam)")!
        let parameters: HTTPHeaders = ["versions[\(release.editId)]": versionId, "notes[\(release.editId)]": release.note ?? "","changes[\(release.editId)]": "1"]
        
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
        let parameters: HTTPHeaders = ["versions[\(release.editId)]": "", "notes[\(release.editId)]": newNote ?? "","changes[\(release.editId)]": "1"]
        
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
        let parameters: HTTPHeaders = ["notes[\(release.editId)]": "", "item[\(release.editId)]": "1", "changes[\(release.editId)]": "1", "choice": "delete"]
        
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
        let parameters: HTTPHeaders = ["notes[\(release.editId)]": release.note ?? "", "item[\(release.editId)]": "1", "changes[\(release.editId)]": "1", "choice": toCollection.urlParam]
        
        RequestHelper.shared.alamofireManager.request(requestURL, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: nil).response { (response) in
            if let statusCode = response.response?.statusCode, statusCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}