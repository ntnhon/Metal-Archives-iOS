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
    static func updateNote(editId: String, newNote: String?, completion: @escaping (Result<Any?, MAError>) -> Void) {
        let requestUrlString = "https://www.metal-archives.com/bookmark/edit-comment/json/1"
        guard let requestUrl = URL(string: requestUrlString) else {
            completion(.failure(.networking(error: .badURL(requestUrlString))))
            return
        }
        let parameters: [String : Any] = ["id": editId, "comment": newNote ?? ""]
        
        RequestHelper.shared.alamofireManager.request(requestUrl, parameters: parameters).response { (response) in
            
            guard let statusCode = response.response?.statusCode else {
                completion(.failure(.networking(error: .unknownStatusCode)))
                return
            }
            
            if statusCode == 200 {
                completion(.success(nil))
            } else {
                completion(.failure(.unknownErrorWithStatusCode(statusCode: statusCode)))
            }
        }
    }
    
    static func bookmark(id: String, action: BookmarkAction, type: MyBookmark, completion: @escaping (Result<Any?, MAError>) -> Void) {
        let requestUrlString = "https://www.metal-archives.com/bookmark/\(action.rawValue)/type/\(type.param)/id/\(id)?json=true"
        guard let requestUrl = URL(string: requestUrlString) else {
            completion(.failure(.networking(error: .badURL(requestUrlString))))
            return
        }
        
        RequestHelper.shared.alamofireManager.request(requestUrl).response { (response) in
            
            guard let statusCode = response.response?.statusCode else {
                completion(.failure(.networking(error: .unknownStatusCode)))
                return
            }
            
            if statusCode == 200 {
                completion(.success(nil))
            } else {
                completion(.failure(.unknownErrorWithStatusCode(statusCode: statusCode)))
            }
        }
    }
}
