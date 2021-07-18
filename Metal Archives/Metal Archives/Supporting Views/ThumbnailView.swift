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

    init(urlString: String?, imageType: ImageType) {
        viewModel = .init(urlString: urlString, imageType: imageType)
    }

    var body: some View {
        if viewModel.isLoading {
            ProgressView()
        } else if let uiImage = viewModel.uiImage {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
        } else {
            Image(systemName: viewModel.imageType.placeholderSystemImageName)
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
        ThumbnailView(urlString: "https://www.metal-archives.com/bands/Death/141",
                      imageType: .bandLogo)
    }
}

enum ImageType {
    case bandLogo, bandPhoto, artist, release, label

    var suffix: String {
        switch self {
        case .bandLogo: return "_logo"
        case .bandPhoto: return "_photo"
        case .artist: return "_artist"
        case .release: return ""
        case .label: return "_label"
        }
    }

    var placeholderSystemImageName: String {
        switch self {
        case .bandLogo: return "photo.fill"
        case .bandPhoto: return "person.3.fill"
        case .artist: return "person.fill"
        case .release: return "opticaldisc"
        case .label: return "tag.fill"
        }
    }
}

enum ImageExtension: String {
    case jpg, jpeg, png, gif
}

fileprivate let kImagesBaseUrlString = "https://www.metal-archives.com/images/"

final class ThumbnailViewModel: ObservableObject {
    private let id: Int?
    let imageType: ImageType

    @Published private(set) var isLoading = false
    @Published private(set) var uiImage: UIImage?
    private var triedJPG = false
    private var triedPNG = false
    private var triedJPEG = false
    private var triedGIF = false
    private var cancellable: AnyCancellable?

    init(urlString: String?, imageType: ImageType) {
        self.id = urlString?.components(separatedBy: "/").last?.toInt()
        self.imageType = imageType
    }

    func tryLoadingNewImage() {
        guard let id = id,
              uiImage == nil,
              let imageUrlString = newImageUrlString(id: id),
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
                print("\(httpResponse.statusCode): \(imageUrlString)")
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
        print("new url: \(id)")
        if !triedJPG {
            print("try jpg: \(id)")
            triedJPG = true
            return kImagesBaseUrlString + id.toImagePath(type: imageType, extension: .jpg)
        }

        if !triedPNG {
            triedPNG = true
            print("try png: \(id)")
            return kImagesBaseUrlString + id.toImagePath(type: imageType, extension: .png)
        }

        if !triedJPEG {
            triedJPEG = true
            print("try jpeg: \(id)")
            return kImagesBaseUrlString + id.toImagePath(type: imageType, extension: .jpeg)
        }

        if !triedGIF {
            triedGIF = true
            print("try gif: \(id)")
            return kImagesBaseUrlString + id.toImagePath(type: imageType, extension: .gif)
        }

        return nil
    }
}

private extension Int {
    func toImagePath(type: ImageType, extension: ImageExtension) -> String {
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
