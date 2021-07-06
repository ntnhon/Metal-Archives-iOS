//
//  BandHeaderView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 29/06/2021.
//

import SwiftUI

struct BandHeaderView: View {
    let band: Band
    var body: some View {
        VStack(spacing: 0) {
            // Logo
            let logoHeight = min(UIScreen.main.bounds.height / 4, 150)
            Image("death_logo")
                .resizable()
                .scaledToFill()
                .frame(height: logoHeight)
                .clipped()

            // Photo
            let photoHeight = min(UIScreen.main.bounds.width / 2, 150)
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
    }
}

struct BandHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            BandHeaderView(band: .death)
        }
    }
}
