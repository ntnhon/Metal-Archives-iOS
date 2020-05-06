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

//MARK: - Review
extension MetalArchivesAPI {
    static func fetchReviewDetail(urlString: String, withCompletion completion: @escaping ((Review?, Error?) -> Void)) {
        RequestHelper.ReviewDetail.fetchReview(urlString: urlString, onSuccess: { (review) in
            completion(review, nil)
        }) { (error) in
            completion(nil, error)
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
    static func reloadArtist(urlString: String, withCompletion completion: @escaping ((Artist?, Error?) -> Void)) {
        RequestHelper.ArtistDetail.fetchArtistDetail(urlString: urlString, onSuccess: { (artist) in
            MetalArchivesAPI.fetchArtistsDetails(artist: artist, withCompletion: { (artist, error) in
                completion(artist, error)
            })
        }) { (error) in
            completion(nil, error)
        }
    }
    
    private static func fetchArtistsDetails(artist: Artist, withCompletion completion: @escaping ((Artist?, Error?) -> Void)) {
        var storedError: Error?
        let fetchGroup = DispatchGroup()
        
        
        //Biography
        fetchGroup.enter()
        RequestHelper.ArtistDetail.fetchArtistBiography(id: artist.id, onSuccess: { (biographyString) in
            artist.setBiography(biographyString: biographyString)
            fetchGroup.leave()
        }) { (error) in
            storedError = error
            fetchGroup.leave()
        }
        
        //Trivia
        fetchGroup.enter()
        RequestHelper.ArtistDetail.fetchArtistTrivia(id: artist.id, onSuccess: { (triviaString) in
            artist.setTrivia(triviaString: triviaString)
            fetchGroup.leave()
        }) { (error) in
            storedError = error
            fetchGroup.leave()
        }
        
        //Links
        fetchGroup.enter()
        RequestHelper.ArtistDetail.fetchArtistLinks(id: artist.id, onSuccess: { (links) in
            artist.setLinks(links: links)
            fetchGroup.leave()
        }) { (error) in
            storedError = error
            fetchGroup.leave()
        }
        
        fetchGroup.notify(queue: DispatchQueue.main) {
            completion(artist, storedError)
        }
    }
}

//MARK: - Label
extension MetalArchivesAPI {
    static func reloadLabel(urlString: String, withCompletion completion: @escaping ((Label?, Error?) -> Void)) {
        RequestHelper.LabelDetail.fetchLabelDetail(urlString: urlString, onSuccess: { (label) in
            MetalArchivesAPI.fetchLabelsDetails(label: label, withCompletion: { (label, error) in
                completion(label, error)
            })
        }) { (error) in
            completion(nil, error)
        }
    }
    
    private static func fetchLabelsDetails(label: Label, withCompletion completion: @escaping ((Label?, Error?) -> Void)) {
        var storedError: Error?
        let fetchGroup = DispatchGroup()
        
        
        //Links
        fetchGroup.enter()
        RequestHelper.LabelDetail.fetchLabelLinks(id: label.id, onSuccess: { (links) in
            label.setLinks(links)
            fetchGroup.leave()
        }) { (error) in
            storedError = error
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
            completion(label, storedError)
        }
    }
}
