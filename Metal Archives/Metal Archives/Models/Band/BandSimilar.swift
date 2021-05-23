//
//  BandSimilar.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

struct BandSimilar {
    let urlString: String
    let name: String
    let country: Country
    let genre: String
    let score: Int
}

extension BandSimilar {
    final class Builder {
        var urlString: String?
        var name: String?
        var country: Country?
        var genre: String?
        var score: Int?

        func build() -> BandSimilar? {
            guard let urlString = urlString else {
                print("[Building BandSimilar] urlString can not be nil.")
                return nil
            }

            guard let name = name else {
                print("[Building BandSimilar] name can not be nil.")
                return nil
            }

            guard let country = country else {
                print("[Building BandSimilar] country can not be nil.")
                return nil
            }

            guard let genre = genre else {
                print("[Building BandSimilar] genre can not be nil.")
                return nil
            }

            guard let score = score else {
                print("[Building BandSimilar] score can not be nil.")
                return nil
            }

            return BandSimilar(urlString: urlString,
                               name: name,
                               country: country,
                               genre: genre,
                               score: score)
        }
    }
}
