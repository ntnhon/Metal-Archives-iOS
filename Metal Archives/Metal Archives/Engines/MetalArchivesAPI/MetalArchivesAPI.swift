//
//  MetalArchivesAPI.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 16/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import Alamofire

final class MetalArchivesAPI {
    private init () {}
}

//MARK: - Band's details
extension MetalArchivesAPI {
    static func reloadBand(bandURLString urlString: String, completion: @escaping (Result<Band, MAError>) -> Void) {
        RequestHelper.BandDetail.fetchBandGeneralInfo(urlString: urlString) { result in
            switch result {
            case .success(let band):
                fetchBandDetails(band: band) { result in
                    switch result {
                    case .success(let band): completion(.success(band))
                    case .failure(let error): completion(.failure(error))
                    }
                }
                
            case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    private static func fetchBandDetails(band: Band, completion: @escaping (Result<Band, MAError>) -> Void) {
        var storedError: MAError?
        let fetchGroup = DispatchGroup()
        
        //Readmore
        fetchGroup.enter()
        RequestHelper.BandDetail.fetchReadMore(bandID: band.id) { result in
            switch result {
            case .success(let readmoreString): band.setReadMoreString(readmoreString)
            case .failure(let error): storedError = error
            }
            
            fetchGroup.leave()
        }
        
        //Discography
        fetchGroup.enter()
        RequestHelper.BandDetail.fetchDiscography(bandID: band.id) { result in
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
        RequestHelper.BandDetail.fetchSimilarArtists(bandID: band.id) { result in
            switch result {
            case .success(let similarBands): band.setSimilarArtists(similarBands)
            case .failure(let error): storedError = error
            }
            
            fetchGroup.leave()
        }
        
        //Related links
        fetchGroup.enter()
        RequestHelper.BandDetail.fetchRelatedLinks(bandID: band.id) { result in
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


//MARK: - Release
extension MetalArchivesAPI {
    static func reloadRelease(urlString: String, completion: @escaping (Result<Release, MAError>) -> Void) {
        RequestHelper.ReleaseDetail.fetchReleaseDetail(urlString: urlString) { result in
            switch result {
            case .success(let release):
                RequestHelper.ReleaseDetail.fetchOtherVersion(releaseID: release.id) { result in
                    switch result {
                    case .success(let otherVersions):
                        release.setOtherVersions(otherVersions)
                        completion(.success(release))
                        
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

//MARK: - Artist
extension MetalArchivesAPI {
    static func reloadArtist(urlString: String, withCompletion completion: @escaping (Result<Artist, MAError>) -> Void) {
        RequestHelper.ArtistDetail.fetchArtistGeneralInfo(urlString: urlString) { result in
            switch result {
            case .success(let artist):
                fetchArtistsDetails(artist: artist) { result in
                    switch result {
                    case .success(let artist): completion(.success(artist))
                    case .failure(let error): completion(.failure(error))
                    }
                }
                
            case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    private static func fetchArtistsDetails(artist: Artist, withCompletion completion: @escaping (Result<Artist, MAError>) -> Void) {
        var storedError: MAError?
        let fetchGroup = DispatchGroup()
        
        //Biography
        fetchGroup.enter()
        RequestHelper.ArtistDetail.fetchArtistBiography(id: artist.id) { result in
            switch result {
            case .success(let biography): artist.setBiography(biographyString: biography)
            case .failure(let error): storedError = error
            }
            
            fetchGroup.leave()
        }
        
        //Trivia
        fetchGroup.enter()
        RequestHelper.ArtistDetail.fetchArtistTrivia(id: artist.id) { result in
            switch result {
            case .success(let trivia): artist.setTrivia(triviaString: trivia)
            case .failure(let error): storedError = error
            }
            
            fetchGroup.leave()
        }
        
        //Links
        fetchGroup.enter()
        RequestHelper.ArtistDetail.fetchArtistLinks(id: artist.id) { result in
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

//MARK: - Label
extension MetalArchivesAPI {
    static func reloadLabel(urlString: String, completion: @escaping (Result<Label, MAError>) -> Void) {
        RequestHelper.LabelDetail.fetchLabelGeneralInfo(urlString: urlString) { result in
            switch result {
            case .success(let label):
                MetalArchivesAPI.fetchLabelDetails(label: label) { result in
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
    
    private static func fetchLabelDetails(label: Label, completion: @escaping (Result<Label, MAError>) -> Void) {
        var storedError: MAError?
        let fetchGroup = DispatchGroup()
        
        //Links
        fetchGroup.enter()
        RequestHelper.LabelDetail.fetchLabelLinks(id: label.id) { result in
            switch result {
            case .success(let links):
                label.setLinks(links)
                fetchGroup.leave()
                
            case .failure(let error):
                storedError = error
                fetchGroup.leave()
            }
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
