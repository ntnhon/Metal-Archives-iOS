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
         onSelectImage: @escaping (UIImage) -> Void) {
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
        .onAppear(perform: viewModel.fetchImages)
    }

    @ViewBuilder
    private var logoView: some View {
        let logoHeight = min(UIScreen.main.bounds.height / 4, 150)
        if viewModel.band.logoUrlString != nil {
            GeometryReader { proxy in
                ZStack {
                    if viewModel.isLoadingLogo {
                        ProgressView()
                            .frame(width: logoHeight, height: logoHeight)
                    }

                    if let logo = viewModel.logo {
                        Image(uiImage: logo)
                            .resizable()
                            .scaledToFit()
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
        if band.photoUrlString != nil {
            ZStack {
                if viewModel.isLoadingPhoto {
                    ProgressView()
                        .frame(width: photoHeight, height: photoHeight)
                }

                if let photo = viewModel.photo {
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
                }
            }
            .clipShape(Rectangle())
            .border(Color(.label), width: 2)
            .padding(.top, band.logoUrlString != nil ? -photoHeight / 3 : 0)
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
