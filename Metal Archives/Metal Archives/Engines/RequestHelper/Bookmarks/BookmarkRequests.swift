//
//  BookmarkRequests.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 11/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

extension RequestHelper {
    final class Bookmark {}
}

extension RequestHelper.Bookmark {
    static func updateNote(editId: String, newNote: String?, completion: @escaping (_ isSuccessful: Bool) -> Void) {
        let requestURL = URL(string: "https://www.metal-archives.com/bookmark/edit-comment/json/1")!
        let parameters: [String : Any] = ["id": editId, "comment": newNote ?? ""]
        
        RequestHelper.shared.alamofireManager.request(requestURL, parameters: parameters).response { (response) in
            if let statusCode = response.response?.statusCode, statusCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    static func bookmark(id: String, action: BookmarkAction, type: BookmarkType, completion: @escaping (_ isSuccessful: Bool) -> Void) {
        let requestURL = URL(string: "https://www.metal-archives.com/bookmark/\(action.rawValue)/type/\(type.rawValue)/id/\(id)?json=true")!
        
        RequestHelper.shared.alamofireManager.request(requestURL).response { (response) in
            if let statusCode = response.response?.statusCode, statusCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}
