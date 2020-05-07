//
//  RequestService+Artist.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 07/05/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

extension RequestService {
    final class Artist {
        private init() {}
    }
}

// MARK: - Exposed function
extension RequestService.Artist {
    static func fetch(urlString: String, completion: @escaping (Result<Artist, MAError>) -> Void) {
        fetchGeneralInfo(urlString: urlString) { result in
            switch result {
            case .success(let artist):
                fetchDetails(artist: artist) { result in
                    switch result {
                    case .success(let artist): completion(.success(artist))
                    case .failure(let error): completion(.failure(error))
                    }
                }
                
            case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    fileprivate static func fetchDetails(artist: Artist, completion: @escaping (Result<Artist, MAError>) -> Void) {
        var storedError: MAError?
        let fetchGroup = DispatchGroup()
        
        //Biography
        fetchGroup.enter()
        fetchBiography(id: artist.id) { result in
            switch result {
            case .success(let biography): artist.setBiography(biographyString: biography)
            case .failure(let error): storedError = error
            }
            
            fetchGroup.leave()
        }
        
        //Trivia
        fetchGroup.enter()
        fetchTrivia(id: artist.id) { result in
            switch result {
            case .success(let trivia): artist.setTrivia(triviaString: trivia)
            case .failure(let error): storedError = error
            }
            
            fetchGroup.leave()
        }
        
        //Links
        fetchGroup.enter()
        fetchLinks(id: artist.id) { result in
            switch result {
            case .success(let links): artist.setLinks(links: links)
            case .failure(let error): storedError = error
            }
            
            fetchGroup.leave()
        }
        
        fetchGroup.notify(queue: DispatchQueue.main) {
            if let error = storedError {
                completion(.failure(error))
            } else {
                completion(.success(artist))
            }
        }
    }
}

// MARK: - Private fetch detail functions
extension RequestService.Artist {
    fileprivate static func fetchGeneralInfo(urlString: String, completion: @escaping (Result<Artist, MAError>) -> Void) {
        guard let requestUrl = URL(string: urlString) else {
            completion(.failure(.networking(error: .badURL(urlString))))
            return
        }
        
        RequestService.shared.alamofireSession.request(requestUrl).responseData { response in
            switch response.result {
            case .success(let data):
                if let artist = Artist(fromData: data, urlString: urlString)  {
                    completion(.success(artist))
                } else {
                    completion(.failure(.parsing(error: .badStructure(anyObject: Artist.self))))
                }
                
            case .failure(let error):
                completion(.failure(.alamofire(error: error)))
            }
        }
    }
    
    fileprivate static func fetchBiography(id: String, completion: @escaping (Result<String?, MAError>) -> Void) {
        let requestUrlString = "https://www.metal-archives.com/artist/read-more/id/" + id
        guard let requestUrl = URL(string: requestUrlString) else {
            completion(.failure(.networking(error: .badURL(requestUrlString))))
            return
        }
        
        RequestService.shared.alamofireSession.request(requestUrl).responseData { (response) in
            switch response.result {
            case .success(let data):
                let biography = String.htmlBodyString(data: data)
                completion(.success(biography))
                
            case .failure(let error):
                switch error {
                case .responseSerializationFailed(let reason):
                    switch reason {
                    case .inputDataNilOrZeroLength: completion(.success(nil))
                    default: completion(.failure(.alamofire(error: error)))
                    }
                    
                default: completion(.failure(.alamofire(error: error)))
                }
            }
        }
    }
    
    fileprivate static func fetchTrivia(id: String, completion: @escaping (Result<String?, MAError>) -> Void) {
        let requestUrlString = "https://www.metal-archives.com/artist/read-more/id/\(id)/field/trivia"
        guard let requestUrl = URL(string: requestUrlString) else {
            completion(.failure(.networking(error: .badURL(requestUrlString))))
            return
        }
        
        RequestService.shared.alamofireSession.request(requestUrl).responseData { response in
            switch response.result {
            case .success(let data):
                let triviaString = String.htmlBodyString(data: data)
                completion(.success(triviaString))
                
            case .failure(let error):
                switch error {
                case .responseSerializationFailed(let reason):
                    switch reason {
                    case .inputDataNilOrZeroLength: completion(.success(nil))
                    default: completion(.failure(.alamofire(error: error)))
                    }
                    
                default: completion(.failure(.alamofire(error: error)))
                }
            }
        }
    }
    
    fileprivate static func fetchLinks(id: String, completion: @escaping (Result<[RelatedLink]?, MAError>) -> Void) {
        let requestUrlString = "https://www.metal-archives.com/link/ajax-list/type/person/id/" + id
        guard let requestUrl = URL(string: requestUrlString) else {
            completion(.failure(.networking(error: .badURL(requestUrlString))))
            return
        }
        
        RequestService.shared.alamofireSession.request(requestUrl).responseData { response in
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
