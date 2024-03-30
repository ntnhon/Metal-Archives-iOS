//
//  BandHeaderView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 29/06/2021.
//

import Kingfisher
import SwiftUI

struct BandHeaderView: View {
    @EnvironmentObject private var preferences: Preferences
    @StateObject private var viewModel: BandHeaderViewModel
    let onSelectImage: (UIImage) -> Void

    init(band: Band,
         onSelectImage: @escaping (UIImage) -> Void)
    {
        _viewModel = .init(wrappedValue: .init(band: band))
        self.onSelectImage = onSelectImage
    }

    var body: some View {
        VStack(spacing: 0) {
            logoView
            photoView
            Text(viewModel.band.name)
                .font(.title)
                .fontWeight(.bold)
                .padding(.vertical)
                .textSelection(.enabled)
        }
        .task {
            await viewModel.fetchImages()
        }
    }

    @ViewBuilder
    private var logoView: some View {
        let logoHeight = min(UIScreen.main.bounds.height / 4, 150)
        if viewModel.band.hasLogo {
            GeometryReader { proxy in
                ZStack {
                    switch viewModel.logoFetchable {
                    case .fetching:
                        ProgressView()
                            .frame(width: logoHeight, height: logoHeight)

                    case let .fetched(logo):
                        if let logo {
                            Image(uiImage: logo)
                                .resizable()
                                .scaledToFit()
                        } else {
                            EmptyView()
                        }

                    case .error:
                        RetryButton(onRetry: viewModel.fetchImages)
                    }
                }
                .clipped()
                .offset(y: min(-proxy.frame(in: .global).minY, 0))
                .frame(width: UIScreen.main.bounds.width,
                       height: max(proxy.frame(in: .global).minY + logoHeight, logoHeight))
                .onTapGesture {
                    if let logo = viewModel.logo {
                        onSelectImage(logo)
                    }
                }
            }
            .frame(height: logoHeight)
        } else {
            Spacer()
        }
    }

    @ViewBuilder
    private var photoView: some View {
        let band = viewModel.band
        let photoHeight = min(UIScreen.main.bounds.width / 2, 150)
        if band.hasPhoto {
            ZStack {
                switch viewModel.photoFetchable {
                case .fetching:
                    ProgressView()
                        .frame(width: photoHeight, height: photoHeight)

                case let .fetched(photo):
                    if let photo {
                        ZStack {
                            Image(uiImage: photo)
                                .resizable()
                                .scaledToFill()
                                .blur(radius: 4)
                                .frame(width: photoHeight, height: photoHeight)

                            Image(uiImage: photo)
                                .resizable()
                                .scaledToFit()
                                .frame(width: photoHeight, height: photoHeight)
                        }
                    } else {
                        EmptyView()
                    }

                case .error:
                    RetryButton(onRetry: viewModel.fetchImages)
                }
            }
            .clipShape(Rectangle())
            .border(Color(.label), width: 2)
            .padding(.top, band.hasLogo ? -photoHeight / 3 : 0)
            .onTapGesture {
                if let photo = viewModel.photo {
                    onSelectImage(photo)
                }
            }
        } else {
            Spacer()
        }
    }
}

struct BandHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            BandHeaderView(band: .death) { _ in }
        }
    }
}
