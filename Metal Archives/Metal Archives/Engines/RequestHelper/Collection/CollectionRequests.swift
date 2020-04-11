//
//  CollectionRequests.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 12/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

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
                releaseVersions.count > 0 ? completion(releaseVersions) : completion(nil)
            } else {
                completion(nil)
            }
        }
    }
}
