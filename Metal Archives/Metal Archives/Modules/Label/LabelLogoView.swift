//
//  LabelLogoView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 05/11/2022.
//

import SwiftUI

struct LabelLogoView: View {
    @EnvironmentObject private var viewModel: LabelViewModel
    @Binding var scaleFactor: CGFloat
    @Binding var opacity: Double

    var body: some View {
        ZStack {
            switch viewModel.logoFetchable {
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
                        Task {
                            await viewModel.fetchLogo()
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.fetchLogo()
        }
    }
}
