//
//  ThumbnailView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 18/07/2021.
//

import Combine
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
                .onAppear {
                    if preferences.showThumbnails {
                        viewModel.tryLoadingNewImage()
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
    private var cancellable: AnyCancellable?

    init(thumbnailInfo: ThumbnailInfo) {
        self.thumbnailInfo = thumbnailInfo
    }

    func tryLoadingNewImage() {
        guard uiImage == nil,
              let imageUrlString = newImageUrlString(id: thumbnailInfo.id),
              let imageUrl = URL(string: imageUrlString) else {
            return
        }
        isLoading = true
        cancellable = URLSession.shared
            .dataTaskPublisher(for: imageUrl)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] data, response in
                guard let self = self,
                      let httpResponse = response as? HTTPURLResponse else { return }
                switch httpResponse.statusCode {
                case 200:
                    self.isLoading = false
                    self.uiImage = .init(data: data)
                case 404:
                    self.isLoading = false
                    self.tryLoadingNewImage()
                case 520:
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        self.resetStates()
                    }
                default: break
                }
            })
    }

    func resetStates() {
        isLoading = false
        triedJPG = false
        triedPNG = false
        triedJPEG = false
        triedJPG = false
        tryLoadingNewImage()
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
