//
//  BandView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 26/06/2021.
//

import SwiftUI

struct BandView: View {
    @EnvironmentObject private var preferences: Preferences
    @ObservedObject private var viewModel: BandViewModel

    init(bandUrlString: String) {
        self.viewModel = .init(bandUrlString: bandUrlString)
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVStack(spacing: 0) {
                    switch viewModel.bandAndDiscographyFetchable {
                    case .error(let error):
                        Text(error.description)
                            .frame(maxWidth: .infinity)

                    case .fetching, .waiting:
                        Text("Fetching band")
                            .frame(maxWidth: .infinity)

                    case .fetched(let (band, discography)):
                        BandHeaderView(band: band)
                        BandInfoView(viewModel: .init(band: band, discography: discography),
                                     onSelectLabel: { _ in },
                                     onSelectBand: { _ in })
                            .padding(.horizontal)
                    }
                } // End of root LazyVStack
            } // End of root ScrollView
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
        .onAppear {
            viewModel.refreshBandAndDiscography()
        }
    }
}

struct BandView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BandView(bandUrlString: "https://www.metal-archives.com/band/random")
        }
        .environment(\.colorScheme, .dark)
        .environmentObject(Preferences())
    }
}
