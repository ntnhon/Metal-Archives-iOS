//
//  RequestArtistTrivia.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 18/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import Kanna

extension RequestHelper.ArtistDetail {
    typealias FetchArtistTriviaOnSuccess = (_ trivia: String?) -> Void
    typealias FetchArtistTriviaOnError = (Error) -> Void
    
    static func fetchArtistTrivia(id: String, onSuccess: @escaping FetchArtistTriviaOnSuccess, onError: @escaping FetchArtistTriviaOnError) {
        let requestURLString = "https://www.metal-archives.com/artist/read-more/id/<ARTIST_ID>/field/trivia".replacingOccurrences(of: "<ARTIST_ID>", with: id)
        let requestURL = URL(string: requestURLString)!
        
        RequestHelper.shared.alamofireManager.request(requestURL).responseData { (response) in
            switch response.result {
            case .success:
                if let data = response.data {
                    let triviaString = RequestHelper.ArtistDetail.extractTrivia(data: data)
                    onSuccess(triviaString)
                }
                
            case .failure(let error): onError(error)
            }
        }
        
    }
    
    private static func extractTrivia(data: Data) -> String? {
        guard let htmlString = String(data: data, encoding: String.Encoding.utf8) else {
            return nil
        }
        
        if let doc = try? Kanna.HTML(html: htmlString, encoding: String.Encoding.utf8) {
            for tag in doc.css("html") {
                let bodyTag = tag.at_css("body")
                if let biographyString =  bodyTag?.text {
                    return biographyString
                }
                
                return nil
            }
            
        }
        
        return nil
    }
}
