//
//  ReleaseCoverView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 08/10/2022.
//

import SwiftUI

struct ReleaseCoverView: View {
    @EnvironmentObject private var viewModel: ReleaseViewModel
    @Binding var scaleFactor: CGFloat
    @Binding var opacity: Double

    var body: some View {
        ZStack {
            switch viewModel.coverFetchable {
            case .fetching:
                ProgressView()

            case let .fetched(image):
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

            case let .error(error):
                VStack {
                    Text(error.userFacingMessage)
                    RetryButton {
                        await viewModel.fetchCoverImage()
                    }
                }
            }
        }
    }
}
