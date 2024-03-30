//
//  ArtistPhotoView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 28/10/2022.
//

import SwiftUI

struct ArtistPhotoView: View {
    @EnvironmentObject private var viewModel: ArtistViewModel
    @Binding var scaleFactor: CGFloat
    @Binding var opacity: Double

    var body: some View {
        ZStack {
            switch viewModel.photoFetchable {
            case .fetching:
                ProgressView()

            case .fetched(let image):
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .blur(radius: 20)
                        .fixedSize(horizontal: false, vertical: true)

                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .padding(50)
                        .scaleEffect(scaleFactor)
                        .opacity(opacity)
                } else {
                    EmptyView()
                }

            case .error(let error):
                VStack {
                    Text(error.userFacingMessage)
                    RetryButton {
                        await viewModel.fetchPhoto()
                    }
                }
            }
        }
    }
}
