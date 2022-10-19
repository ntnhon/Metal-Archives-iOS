//
//  ThumbnailView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 18/07/2021.
//

import SwiftUI

struct ThumbnailView: View {
    @EnvironmentObject private var preferences: Preferences
    @EnvironmentObject private var cache: MAImageCache
    @ObservedObject private var viewModel: ThumbnailViewModel
    @Environment(\.selectedPhoto) private var selectedPhoto
    private let photoDescription: String

    init(thumbnailInfo: ThumbnailInfo,
         photoDescription: String,
         cache: MAImageCache) {
        self.viewModel = .init(thumbnailInfo: thumbnailInfo, cache: cache)
        self.photoDescription = photoDescription
    }

    var body: some View {
        if viewModel.isLoading {
            ZStack {
                Color.clear
                ProgressView()
            }
        } else if let uiImage = viewModel.uiImage {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .onTapGesture {
                    selectedPhoto.wrappedValue =
                    Photo(image: uiImage,
                          description: photoDescription)
                }
        } else {
            Image(systemName: viewModel.thumbnailInfo.type.placeholderSystemImageName)
                .resizable()
                .scaledToFit()
                .onAppear {
                    Task {
                        if preferences.showThumbnails {
                            await viewModel.tryLoadingNewImage()
                        }
                    }
                }
        }
    }
}

struct ThumbnailView_Previews: PreviewProvider {
    static var previews: some View {
        ThumbnailView(thumbnailInfo: .death, photoDescription: "", cache: .init())
    }
}

enum ImageExtension: String {
    case jpg, jpeg, png, gif
}

fileprivate let kImagesBaseUrlString = "https://www.metal-archives.com/images/"

final class ThumbnailViewModel: ObservableObject {
    private let cache: MAImageCache
    let thumbnailInfo: ThumbnailInfo

    @Published private(set) var isLoading = false
    @Published private(set) var uiImage: UIImage?
    private var triedJPG = false
    private var triedPNG = false
    private var triedJPEG = false
    private var triedGIF = false

    init(thumbnailInfo: ThumbnailInfo, cache: MAImageCache) {
        self.thumbnailInfo = thumbnailInfo
        self.cache = cache
    }

    @MainActor
    func tryLoadingNewImage() async {
        guard uiImage == nil,
              let imageUrlString = newImageUrlString(id: thumbnailInfo.id),
              let imageUrl = URL(string: imageUrlString) else {
            return
        }
        isLoading = true
        do {
            if let image = try await cache.retrieveImage(forKey: imageUrlString) {
                isLoading = false
                self.uiImage = image
                return
            }

            let (data, response) = try await URLSession.shared.data(for: .init(url: imageUrl))
            guard let httpResponse = response as? HTTPURLResponse else {
                await tryLoadingNewImage()
                return
            }

            switch httpResponse.statusCode {
            case 200:
                isLoading = false
                if let image = UIImage(data: data) {
                    self.uiImage = image
                    try await cache.storeImage(image, forKey: imageUrlString)
                }
            case 404:
                isLoading = false
                await tryLoadingNewImage()
            case 520:
                try await Task.sleep(nanoseconds: 5_000_000_000)
                isLoading = false
                triedJPG = false
                triedPNG = false
                triedJPEG = false
                triedJPG = false
                await tryLoadingNewImage()
            default:
                break
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    private func newImageUrlString(id: Int) -> String? {
        if !triedJPG {
            triedJPG = true
            return kImagesBaseUrlString + id.toImagePath(type: thumbnailInfo.type, extension: .jpg)
        }

        if !triedPNG {
            triedPNG = true
            return kImagesBaseUrlString + id.toImagePath(type: thumbnailInfo.type, extension: .png)
        }

        if !triedJPEG {
            triedJPEG = true
            return kImagesBaseUrlString + id.toImagePath(type: thumbnailInfo.type, extension: .jpeg)
        }

        if !triedGIF {
            triedGIF = true
            return kImagesBaseUrlString + id.toImagePath(type: thumbnailInfo.type, extension: .gif)
        }

        return nil
    }
}

private extension Int {
    func toImagePath(type: ThumbnailType, extension: ImageExtension) -> String {
        let idString = "\(self)"

        var imagePath = ""
        switch self {
        case 1_000...Int.max:
            imagePath = "\(idString[0])/\(idString[1])/\(idString[2])/\(idString[3])/"
        case 100...999:
            imagePath = "\(idString[0])/\(idString[1])/\(idString[2])/"
        case 10...99:
            imagePath = "\(idString[0])/\(idString[1])/"
        default:
            imagePath = idString
        }

        imagePath += idString + type.suffix + "." + `extension`.rawValue
        return imagePath
    }
}
