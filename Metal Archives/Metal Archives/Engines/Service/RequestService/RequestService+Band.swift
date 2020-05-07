//
//  RequestService+Band.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 07/05/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

extension RequestService {
    final class Band {
        private init() {}
    }
}

// MARK: - Exposed function
extension RequestService.Band {
    static func fetch(urlString: String, completion: @escaping (Result<Band, MAError>) -> Void) {
        RequestService.Band.fetchGeneralInfo(urlString: urlString) { result in
            switch result {
            case .success(let band):
                fetchDetails(band: band) { result in
                    switch result {
                    case .success(let band): completion(.success(band))
                    case .failure(let error): completion(.failure(error))
                    }
                }
                
            case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    fileprivate static func fetchDetails(band: Band, completion: @escaping (Result<Band, MAError>) -> Void) {
        var storedError: MAError?
        let fetchGroup = DispatchGroup()
        
        //Readmore
        fetchGroup.enter()
        fetchReadMore(bandID: band.id) { result in
            switch result {
            case .success(let readmoreString): band.setReadMoreString(readmoreString)
            case .failure(let error): storedError = error
            }
            
            fetchGroup.leave()
        }
        
        //Discography
        fetchGroup.enter()
        fetchDiscography(bandID: band.id) { result in
            switch result {
            case .success(let discography): band.setDiscography(discography)
            case .failure(let error): storedError = error
            }
            
            fetchGroup.leave()
        }
        
        //Reviews
        fetchGroup.enter()
        band.reviewLitePagableManager.fetch { (error) in
            // Don't care about this error because server randomly throws unknown error
            fetchGroup.leave()
        }
        
        //Similar artists
        fetchGroup.enter()
        fetchSimilarArtists(bandID: band.id) { result in
            switch result {
            case .success(let similarBands): band.setSimilarArtists(similarBands)
            case .failure(let error): storedError = error
            }
            
            fetchGroup.leave()
        }
        
        //Related links
        fetchGroup.enter()
        fetchRelatedLinks(bandID: band.id) { result in
            switch result {
            case .success(let relatedLinks): band.setRelatedLinks(relatedLinks)
            case .failure(let error): storedError = error
            }
            
            fetchGroup.leave()
        }

        fetchGroup.notify(queue: DispatchQueue.main) {
            if let error = storedError {
                completion(.failure(error))
            } else {
                band.associateReleasesToReviews()
                completion(.success(band))
            }
        }
    }
}

// MARK: - Private fetch detail functions
extension RequestService.Band {
    fileprivate static func fetchGeneralInfo(urlString: String, completion: @escaping (Result<Band, MAError>) -> Void) {
        guard let requestUrl = URL(string: urlString) else {
            completion(.failure(.networking(error: .badURL(urlString))))
            return
        }
        
        RequestService.shared.alamofireSession.request(requestUrl).responseData { response in
            switch response.result {
            case .success(let data):
                if let band = Band.init(fromData: data) {
                    completion(.success(band))
                } else {
                    completion(.failure(.parsing(error: .badStructure(anyObject: Band.self))))
                }
                
            case .failure(let error):
                completion(.failure(.alamofire(error: error)))
            }
        }
    }
    
    fileprivate static func fetchReadMore(bandID: String, completion: @escaping (Result<String, MAError>) -> Void) {
        let requestUrlString = "https://www.metal-archives.com/band/read-more/id/" + bandID
        guard let requestUrl = URL(string: requestUrlString) else {
            completion(.failure(.networking(error: .badURL(requestUrlString))))
            return
        }
        
        RequestService.shared.alamofireSession.request(requestUrl).responseData { response in
            let defaultMessage = "No information added"
            switch response.result {
            case .success(let data):
                let readMoreString = String.htmlBodyString(data: data)
                completion(.success(readMoreString ?? defaultMessage))
                
            case .failure(let error):
                switch error {
                case .responseSerializationFailed(let reason):
                    switch reason {
                    case .inputDataNilOrZeroLength: completion(.success(defaultMessage))
                    default: completion(.failure(.alamofire(error: error)))
                    }
                default: completion(.failure(.alamofire(error: error)))
                }
            }
        }
    }
    
    fileprivate static func fetchDiscography(bandID: String, completion: @escaping (Result<Discography?, MAError>) -> Void) {
        let requestUrlString = "https://www.metal-archives.com/band/discography/id/\(bandID)/tab/all"
        guard let requestUrl = URL(string: requestUrlString) else {
            completion(.failure(.networking(error: .badURL(requestUrlString))))
            return
        }
        
        RequestService.shared.alamofireSession.request(requestUrl).responseData { response in
            switch response.result {
            case .success(let data):
                let discography = Discography.init(data: data)
                completion(.success(discography))
                
            case .failure(let error):
                completion(.failure(.alamofire(error: error)))
            }
        }
    }
    
    fileprivate static func fetchSimilarArtists(bandID: String, completion: @escaping (Result<[BandSimilar]?, MAError>) -> Void) {
        let requestUrlString = "https://www.metal-archives.com/band/ajax-recommendations/id/\(bandID)/showMoreSimilar/1"
        guard let requestUrl = URL(string: requestUrlString) else {
            completion(.failure(.networking(error: .badURL(requestUrlString))))
            return
        }
        
        RequestService.shared.alamofireSession.request(requestUrl).responseData { response in
            switch response.result {
            case .success(let data):
                let similarBands = [BandSimilar].from(data: data)
                completion(.success(similarBands))
                
            case .failure(let error):
                completion(.failure(.alamofire(error: error)))
            }
        }
    }
    
    fileprivate static func fetchRelatedLinks(bandID: String, completion: @escaping (Result<[RelatedLink]?, MAError>) -> Void) {
        let requestUrlString = "https://www.metal-archives.com/link/ajax-list/type/band/id/" + bandID
        guard let requestUrl = URL(string: requestUrlString) else {
            completion(.failure(.networking(error: .badURL(requestUrlString))))
            return
        }
        
        RequestService.shared.alamofireSession.request(requestUrl).responseData { response in
            switch response.result {
            case .success(let data):
                let relatedLinks = [RelatedLink].from(data: data)
                completion(.success(relatedLinks))
                
            case .failure(let error):
                completion(.failure(.alamofire(error: error)))
            }
        }
    }
}
