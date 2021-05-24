//
//  ArtistLite.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

struct ArtistLite {
    let urlString: String
    let name: String
    let instruments: String
    let bands: [BandLite]
    let seeAlso: String?
}

extension ArtistLite {
    final class Builder {
        var urlString: String?
        var name: String?
        var instruments: String?
        var bands: [BandLite]?
        var seeAlso: String?

        func build() -> ArtistLite? {
            guard let urlString = urlString else {
                print("[Building ArtistLite] urlString can not be nil.")
                return nil
            }

            guard let name = name else {
                print("[Building ArtistLite] name can not be nil.")
                return nil
            }

            guard let instruments = instruments else {
                print("[Building ArtistLite] instruments can not be nil.")
                return nil
            }

            guard let bands = bands else {
                print("[Building ArtistLite] bands can not be nil.")
                return nil
            }

            return ArtistLite(urlString: urlString,
                              name: name,
                              instruments: instruments,
                              bands: bands,
                              seeAlso: seeAlso)
        }
    }
}
