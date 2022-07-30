//
//  BandHeaderView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 29/06/2021.
//

import Kingfisher
import SwiftUI

struct BandHeaderView: View {
    @State private var bandPhotoImage: UIImage?
    @State private var bandLogoImage: UIImage?
    let band: Band
    let onSelectImage: (UIImage) -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Logo
            let logoHeight = min(UIScreen.main.bounds.height / 4, 150)
            if let logoUrlString = band.logoUrlString,
               let logoUrl = URL(string: logoUrlString) {
                GeometryReader { proxy in
                    KFImage
                        .url(logoUrl)
                        .resizable()
                        .placeholder {
                            ProgressView()
                                .frame(width: logoHeight, height: logoHeight)
                        }
                        .onSuccess { result in
                            if let cgImage = result.image.cgImage {
                                self.bandLogoImage = UIImage(cgImage: cgImage)
                            }
                        }
                        .scaledToFit()
                        .clipped()
                        .offset(y: min(-proxy.frame(in: .global).minY, 0))
                        .frame(width: UIScreen.main.bounds.width,
                               height: max(proxy.frame(in: .global).minY + logoHeight, logoHeight))
                        .onTapGesture {
                            if let bandLogoImage = bandLogoImage {
                                onSelectImage(bandLogoImage)
                            }
                        }
                }
                .frame(height: logoHeight)
            } else {
                Spacer()
            }

            bandPhotoView

            // Name
            Text(band.name)
                .font(.title)
                .fontWeight(.bold)
                .padding(.vertical)
                .textSelection(.enabled)
        }
    }

    @ViewBuilder
    private var bandPhotoView: some View {
        let photoHeight = min(UIScreen.main.bounds.width / 2, 150)
        if let photoUrlString = band.photoUrlString,
           let photoUrl = URL(string: photoUrlString) {
            KFImage
                .url(photoUrl)
                .resizable()
                .placeholder {
                    ProgressView()
                        .frame(width: photoHeight, height: photoHeight)
                }
                .onSuccess { result in
                    if let cgImage = result.image.cgImage {
                        self.bandPhotoImage = UIImage(cgImage: cgImage)
                    }
                }
                .scaledToFit()
                .frame(width: photoHeight, height: photoHeight)
                .overlay(
                    Circle()
                        .stroke(band.status.color,
                                style: .init(lineWidth: 6,
                                             lineCap: .round))
                )
                .background(Color(.systemBackground))
                .clipShape(Circle())
                .padding(.top, band.logoUrlString != nil ? -photoHeight / 3 : 0)
                .onTapGesture {
                    if let bandPhotoImage = bandPhotoImage {
                        onSelectImage(bandPhotoImage)
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
