//
//  KingfisherManager+fetchImageAsync.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 08/10/2022.
//

import Kingfisher
import UIKit

extension KingfisherManager {
    func retrieveImage(with url: URL) async throws -> UIImage? {
        try await withCheckedThrowingContinuation { continuation in
            retrieveImage(with: url) { result in
                switch result {
                case .success(let imageResult):
                    #if DEBUG
                    print("\(imageResult.cacheType): \(url.absoluteString)")
                    #endif
                    if let cgImage = imageResult.image.cgImage {
                        let image = UIImage(cgImage: cgImage)
                        continuation.resume(returning: image)
                    } else {
                        continuation.resume(returning: nil)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
