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
    static func reloadBand(bandURLString urlString: String, withCompletion completion: @escaping ((Band?, Error?) -> Void)) {
        
        RequestHelper.BandDetail.fetchBandDetail(urlString: urlString, onSuccess: { (fetchedBand) in
            MetalArchivesAPI.fetchBandDetails(band: fetchedBand, withCompletion: { (band, error) in
                completion(band, error)
            })
        }) { (error) in
            completion(nil, error)
        }
    }
    
    private static func fetchBandDetails(band: Band, withCompletion completion: @escaping ((Band?, Error?) -> Void)) {
        var storedError: Error?
        let fetchGroup = DispatchGroup()
        
        //Readmore
        fetchGroup.enter()
        RequestHelper.BandDetail.fetchReadMore(bandID: band.id, onSuccess: { (readMoreString) in
            band.setReadMoreString(readMoreString)
            fetchGroup.leave()
        }) { (error) in
            storedError = error
            fetchGroup.leave()
        }
        
        //Discography
        fetchGroup.enter()
        RequestHelper.BandDetail.fetchDiscography(bandID: band.id, onSuccess: { (fetchedDiscography) in
            band.setDiscography(fetchedDiscography)
            fetchGroup.leave()
        }) { (error) in
            storedError = error
            fetchGroup.leave()
        }
        
        //Reviews
        fetchGroup.enter()
        band.reviewLitePagableManager.fetch { (error) in
            // Don't care about this error because server randomly throws unknown error
            // storedError = error
            fetchGroup.leave()
        }
        
        //Similar artists
        fetchGroup.enter()
        RequestHelper.BandDetail.fetchSimilarArtists(bandID: band.id, onSuccess: { (fetchedSimilarArtists) in
            band.setSimilarArtists(fetchedSimilarArtists)
            fetchGroup.leave()
        }) { (error) in
            storedError = error
            fetchGroup.leave()
        }
        
        //Related links
        fetchGroup.enter()
        RequestHelper.BandDetail.fetchRelatedLinks(bandID: band.id, onSuccess: { (fetchedRelatedLinks) in
            band.setRelatedLinks(fetchedRelatedLinks)
            fetchGroup.leave()
        }) { (error) in
            storedError = error
            fetchGroup.leave()
        }
        
        fetchGroup.notify(queue: DispatchQueue.main) {
            band.associateReleasesToReviews()
            completion(band, storedError)
        }
    }
}


//MARK: - Release
extension MetalArchivesAPI {
    static func reloadRelease(urlString: String, withCompletion completion: @escaping ((Release?, Error?) -> Void)) {
        
        RequestHelper.ReleaseDetail.fetchReleaseDetail(urlString: urlString, onSuccess: { (release) in
            
            MetalArchivesAPI.fetchOtherVersions(releaseID: release.id, onSuccess: { (otherVersions) in
                release.setOtherVersions(otherVersions)
                completion(release, nil)
            }, onError: { (error) in
                completion(nil, error)
            })
        }) { (error) in
            completion(nil, error)
        }
    }
    
    private static func fetchOtherVersions(releaseID: String, onSuccess: @escaping ([ReleaseOtherVersion]) -> Void, onError: @escaping (Error) -> Void) {
        RequestHelper.ReleaseDetail.fetchOtherVersion(releaseID: releaseID, onSuccess: { (otherVersions) in
            onSuccess(otherVersions)
        }) { (error) in
            onError(error)
        }
    }
}

//MARK: - Lyric
extension MetalArchivesAPI {
    static func fetchLyric(lyricID: String, withCompletion completion: @escaping ((String?, Error?) -> Void)) {
        RequestHelper.ReleaseDetail.fetchLyric(lyricID: lyricID, onSuccess: { (lyric) in
            completion(lyric, nil)
        }) { (error) in
            completion(nil, error)
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
