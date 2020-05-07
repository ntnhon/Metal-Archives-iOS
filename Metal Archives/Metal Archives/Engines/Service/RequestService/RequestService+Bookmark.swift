//
//  RequestService+Bookmark.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 07/05/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

extension RequestService {
    final class Bookmark {
        private init() {}
    }
}

extension RequestService.Bookmark {
    static func updateNote(editId: String, newNote: String?, completion: @escaping (Result<Any?, MAError>) -> Void) {
        let requestUrlString = "https://www.metal-archives.com/bookmark/edit-comment/json/1"
        guard let requestUrl = URL(string: requestUrlString) else {
            completion(.failure(.networking(error: .badURL(requestUrlString))))
            return
        }
        let parameters: [String : Any] = ["id": editId, "comment": newNote ?? ""]
        
        RequestService.shared.alamofireSession.request(requestUrl, parameters: parameters).response { (response) in
            
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
        
        RequestService.shared.alamofireSession.request(requestUrl).response { (response) in
            
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
