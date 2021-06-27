//
//  BandView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 26/06/2021.
//

import SwiftUI

struct BandView: View {
    @EnvironmentObject private var preferences: Preferences
    let band: Band
    let discography: Discography

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVStack(spacing: 0) {
                    Group {
                        // Logo
                        let logoHeight = min(geometry.size.height / 4, 150)
                        Image("death_logo")
                            .resizable()
                            .scaledToFill()
                            .frame(height: logoHeight)
                            .clipped()

                        // Photo
                        let photoHeight = min(geometry.size.width / 2, 150)
                        Image("death_photo")
                            .resizable()
                            .scaledToFill()
                            .frame(width: photoHeight)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color(.systemBackground), lineWidth: 6)
                            )
                            .padding(.top, -photoHeight / 3)

                        // Name
                        Text(band.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.vertical)
                    }

                    BandInfoView(viewModel: .init(band: band, discography: discography),
                                 onSelectLabel: { labelUrlString in },
                                 onSelectBand: { bandUrlString in })
                } // End of root LazyVStack
            } // End of root ScrollView
        }
        .ignoresSafeArea()
    }
}

struct BandView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BandView(band: .death, discography: .death)
        }
        .environment(\.colorScheme, .dark)
        .environmentObject(Preferences())
    }
}
