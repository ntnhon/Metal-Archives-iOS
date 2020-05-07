//
//  RequestService+Label.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 07/05/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

extension RequestService {
    final class Label {
        private init() {}
    }
}

// MARK: - Exposed function
extension RequestService.Label {
    static func fetch(urlString: String, completion: @escaping (Result<Label, MAError>) -> Void) {
        fetchGeneralInfo(urlString: urlString) { result in
            switch result {
            case .success(let label):
                fetchDetails(label: label) { result in
                    switch result {
                    case .success(let label): completion(.success(label))
                    case .failure(let error): completion(.failure(error))
                    }
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    fileprivate static func fetchDetails(label: Label, completion: @escaping (Result<Label, MAError>) -> Void) {
        var storedError: MAError?
        let fetchGroup = DispatchGroup()
        
        //Links
        fetchGroup.enter()
        fetchLinks(id: label.id) { result in
            switch result {
            case .success(let links): label.setLinks(links)
            case .failure(let error): storedError = error
            }
            
            fetchGroup.leave()
        }
        
        //Current roster
        fetchGroup.enter()
        label.currentRosterPagableManager.fetch { (error) in
            storedError = error
            fetchGroup.leave()
        }
        
        //Past roster
        fetchGroup.enter()
        label.pastRosterPagableManager.fetch { (error) in
            storedError = error
            fetchGroup.leave()
        }
        
        //Releases
        fetchGroup.enter()
        label.releasesPagableManager.fetch { (error) in
            storedError = error
            fetchGroup.leave()
        }
        
        fetchGroup.notify(queue: DispatchQueue.main) {
            if let error = storedError {
                completion(.failure(error))
            } else {
                completion(.success(label))
            }
        }
    }
}

// MARK: - Private fetch detail functions
extension RequestService.Label {
    fileprivate static func fetchGeneralInfo(urlString: String, completion: @escaping (Result<Label, MAError>) -> Void) {
        guard let requestUrl = URL(string: urlString) else {
            completion(.failure(.networking(error: .badURL(urlString))))
            return
        }
        
        RequestService.shared.alamofireManager.request(requestUrl).responseData { (response) in
            switch response.result {
            case .success(let data):
                if let label = Label.init(fromData: data, urlString: urlString) {
                    completion(.success(label))
                } else {
                    completion(.failure(.parsing(error: .badStructure(anyObject: Label.self))))
                }
                
            case .failure(let error):
                completion(.failure(.alamofire(error: error)))
            }
        }
    }

    fileprivate static func fetchLinks(id: String, completion: @escaping (Result<[RelatedLink]?, MAError>) -> Void) {
        let requestUrlString = "https://www.metal-archives.com/link/ajax-list/type/label/id/" + id
        guard let requestUrl = URL(string: requestUrlString) else {
            completion(.failure(.networking(error: .badURL(requestUrlString))))
            return
        }
        
        RequestService.shared.alamofireManager.request(requestUrl).responseData { (response) in
            switch response.result {
            case .success(let data):
                let links = [RelatedLink].from(data: data)
                completion(.success(links))
                
            case .failure(let error):
                completion(.failure(.alamofire(error: error)))
            }
        }
    }
}
