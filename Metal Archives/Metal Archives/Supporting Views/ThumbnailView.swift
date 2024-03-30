//
//  ThumbnailView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 18/07/2021.
//

import Kingfisher
import SwiftUI

struct ThumbnailView: View {
    @EnvironmentObject private var preferences: Preferences
    @ObservedObject private var viewModel: ThumbnailViewModel
    @Environment(\.selectedPhoto) private var selectedPhoto
    private let photoDescription: String

    init(thumbnailInfo: ThumbnailInfo, photoDescription: String) {
        self.viewModel = .init(thumbnailInfo: thumbnailInfo)
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
                .task {
                    if preferences.showThumbnails {
                        await viewModel.tryLoadingNewImage()
                    }
                }
        }
    }
}

struct ThumbnailView_Previews: PreviewProvider {
    static var previews: some View {
        ThumbnailView(thumbnailInfo: .death, photoDescription: "")
    }
}

enum ImageExtension: String {
    case jpg, jpeg, png, gif
}

fileprivate let kImagesBaseUrlString = "https://www.metal-archives.com/images/"

final class ThumbnailViewModel: ObservableObject {
    let thumbnailInfo: ThumbnailInfo

    @Published private(set) var isLoading = false
    @Published private(set) var uiImage: UIImage?
    private var triedJPG = false
    private var triedPNG = false
    private var triedJPEG = false
    private var triedGIF = false

    init(thumbnailInfo: ThumbnailInfo) {
        self.thumbnailInfo = thumbnailInfo
    }

    @MainActor
    func tryLoadingNewImage() async {
        defer { isLoading = false }
        let matcher = ThumbnailInfoMatcher.shared
        guard uiImage == nil,
              let imageUrlString =
                matcher.getMatchedUrlString(for: thumbnailInfo) ?? newImageUrlString(id: thumbnailInfo.id),
              let imageUrl = URL(string: imageUrlString) else {
            return
        }
        isLoading = true
        do {
            uiImage = try await KingfisherManager.shared.retrieveImage(with: imageUrl)
            ThumbnailInfoMatcher.shared.setMatched(thumbnailInfo: thumbnailInfo, urlString: imageUrlString)
        } catch {
            if let kingfisherError = error as? KingfisherError,
               case .responseError(let reason) = kingfisherError,
               case .invalidHTTPStatusCode(let httpResponse) = reason {
                switch httpResponse.statusCode {
                case 404:
                    await tryLoadingNewImage()
                case 520:
                    try? await Task.sleep(nanoseconds: 5_000_000_000)
                    isLoading = false
                    triedJPG = false
                    triedPNG = false
                    triedJPEG = false
                    triedJPG = false
                    await tryLoadingNewImage()
                default:
                    break
                }
            }
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
