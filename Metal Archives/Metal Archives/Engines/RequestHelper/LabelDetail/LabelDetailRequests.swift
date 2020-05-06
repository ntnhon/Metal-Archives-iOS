//
//  LabelDetailRequests.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 06/05/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

extension RequestHelper {
    final class LabelDetail {}
}

extension RequestHelper.LabelDetail {

    static func fetchLabelGeneralInfo(urlString: String, completion: @escaping (Result<Label, MAError>) -> Void) {
        guard let requestUrl = URL(string: urlString) else {
            completion(.failure(.networking(error: .badURL(urlString))))
            return
        }
        
        RequestHelper.shared.alamofireManager.request(requestUrl).responseData { (response) in
            switch response.result {
            case .success(let data):
                if let label = Label.init(fromData: data, urlString: urlString) {
                    completion(.success(label))
                } else {
                    completion(.failure(.parsing(error: .badStructure(anyObject: Label.self))))
                }
                
            case .failure(let error):
                completion(.failure(.unknown(description: error.localizedDescription)))
            }
        }
    }

    static func fetchLabelLinks(id: String, completion: @escaping (Result<[RelatedLink]?, MAError>) -> Void) {
        let requestUrlString = "https://www.metal-archives.com/link/ajax-list/type/label/id/" + id
        guard let requestUrl = URL(string: requestUrlString) else {
            completion(.failure(.networking(error: .badURL(requestUrlString))))
            return
        }
        
        RequestHelper.shared.alamofireManager.request(requestUrl).responseData { (response) in
            switch response.result {
            case .success(let data):
                let links = [RelatedLink].from(data: data)
                completion(.success(links))
                
            case .failure(let error):
                completion(.failure(.unknown(description: error.localizedDescription)))
            }
        }
    }
}
