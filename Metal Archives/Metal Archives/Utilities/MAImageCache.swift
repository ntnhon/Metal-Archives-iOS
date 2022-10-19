//
//  MAImageCache.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 19/10/2022.
//

import Kingfisher
import UIKit

final class MAImageCache: ObservableObject {
    private let cache = ImageCache(name: "MetalArchives")

    init() {}

    func retrieveImage(forKey key: String) async throws -> UIImage? {
        try await withCheckedThrowingContinuation { continuation in
            cache.retrieveImageInDiskCache(forKey: key) { result in
                switch result {
                case .success(let image):
                    continuation.resume(returning: image)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func storeImage(_ image: UIImage, forKey key: String) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) -> Void in
            cache.store(image, forKey: key) { result in
                switch result.diskCacheResult {
                case .failure(let error):
                    continuation.resume(throwing: error)
                default:
                    break
                }
                continuation.resume()
            }
        }
    }
}
