//
//  BandHeaderView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 29/06/2021.
//

import Kingfisher
import SwiftUI

// swiftlint:disable let_var_whitespace
struct BandHeaderView: View {
    let band: Band
    var body: some View {
        VStack(spacing: 0) {
            // Logo
            let logoHeight = min(UIScreen.main.bounds.height / 4, 150)
            if let logoUrlString = band.logoUrlString,
               let logoUrl = URL(string: logoUrlString) {
                KFImage(logoUrl)
                    .resizable()
                    .scaledToFit()
                    .frame(height: logoHeight)
                    .clipped()
            } else {
                Spacer()
            }

            bandPhotoView

            // Name
            Text(band.name)
                .font(.title)
                .fontWeight(.bold)
                .padding(.vertical)
        }
    }

    @ViewBuilder
    private var bandPhotoView: some View {
        let photoHeight = min(UIScreen.main.bounds.width / 2, 150)
        if let photoUrlString = band.photoUrlString,
           let photoUrl = URL(string: photoUrlString) {
            KFImage(photoUrl)
                .placeholder {
                    ProgressView()
                        .frame(width: photoHeight, height: photoHeight)
                }
                .resizable()
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
        } else {
            Spacer()
        }
    }
}

struct BandHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            BandHeaderView(band: .death)
        }
    }
}
