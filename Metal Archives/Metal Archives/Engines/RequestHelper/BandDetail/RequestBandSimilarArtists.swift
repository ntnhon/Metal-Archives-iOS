//
//  RequestBandSimilarArtists.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 05/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import Kanna

extension RequestHelper.BandDetail {
    typealias FetchSimilarArtistsOnSuccess = (_ similarArtists: [BandSimilar]?) -> Void
    typealias FetchSimilarArtistsOnError = (Error) -> Void
    private static let requestSimilarArtistsURLString = "https://www.metal-archives.com/band/ajax-recommendations/id/<BAND_ID>/showMoreSimilar/1"
    
    static func fetchSimilarArtists(bandID: String, onSuccess: @escaping FetchSimilarArtistsOnSuccess, onError: @escaping FetchSimilarArtistsOnError) {
        let requestURLString = requestSimilarArtistsURLString.replacingOccurrences(of: "<BAND_ID>", with: bandID)
        let requestURL = URL(string: requestURLString)!
        
        RequestHelper.shared.alamofireManager.request(requestURL).responseData { (response) in
            switch response.result {
            case .success:
                if let data = response.data {
                    let similarArtists = self.extractSimilarArtists(data: data)
                    onSuccess(similarArtists)
                }
                
            case .failure(let error): onError(error)
            }
        }
    }
    
    private static func extractSimilarArtists(data: Data) -> [BandSimilar]? {
        guard let htmlString = String(data: data, encoding: String.Encoding.utf8) else {
            return nil
        }
        
        var arraySimilarArtists = [BandSimilar]()
        
        if let doc = try? Kanna.HTML(html: htmlString, encoding: String.Encoding.utf8) {
            if let tbody = doc.at_css("tbody") {
                for tr in tbody.css("tr") {
                    var bandName: String?
                    var bandURLString: String?
                    var bandCountry: Country?
                    var bandGenre: String?
                    var bandSimilarScore: Int?
                    var i = 0
                    for td in tr.css("td") {
                        
                        if (td["id"] == "no_artists" || td["id"] == "show_more") {
                            break
                        }
                        
                        if (i == 0) {
                            if let a = td.at_css("a") {
                                bandName = a.text
                                bandURLString = a["href"]
                            }
                        }
                            
                        else if (i == 1) {
                            if let countryName = td.text {
                                bandCountry = Country(name: countryName)
                            }
                        }
                            
                        else if (i == 2) {
                            bandGenre = td.text
                        }
                            
                        else if (i == 3) {
                            if let span = td.at_css("span") {
                                bandSimilarScore = Int(span.text?.replacingOccurrences(of: " ", with: "") ?? "")
                            }
                        }
                        
                        i = i + 1
                    }
                    
                    if let name = bandName, let urlString = bandURLString, let country = bandCountry, let genre = bandGenre, let score = bandSimilarScore {
                        if let band = BandSimilar(name: name, urlString: urlString, country: country, genre: genre, score: score) {
                            arraySimilarArtists.append(band)
                        }
                    }
                    
                }
            }
        }
        
        if arraySimilarArtists.count == 0 {
            return nil
        }
        
        return arraySimilarArtists
    }
}
