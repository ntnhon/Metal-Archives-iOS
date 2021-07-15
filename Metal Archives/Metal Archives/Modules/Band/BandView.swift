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
    @State private var selectedSection: BandSection = .discography

    init(bandUrlString: String) {
        self.viewModel = .init(bandUrlString: bandUrlString)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                switch viewModel.bandAndDiscographyFetchable {
                case .error(let error):
                    Text(error.description)
                        .frame(maxWidth: .infinity)

                case .fetching, .waiting:
                    Text("Fetching band")
                        .frame(maxWidth: .infinity)

                case .fetched(let (band, discography)):
                    primaryContent(band: band,
                                   discography: discography )
                }
            } // End of root LazyVStack
        } // End of root ScrollView
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
        .onAppear {
            viewModel.refreshBandAndDiscography()
        }
    }

    @ViewBuilder
    private func primaryContent(band: Band,
                                discography: Discography) -> some View {
        BandHeaderView(band: band)

        BandInfoView(viewModel: .init(band: band, discography: discography),
                     onSelectLabel: { _ in },
                     onSelectBand: { _ in })
            .padding(.horizontal)

        Color(.systemGray6)
            .frame(height: 10)
            .padding(.vertical)

        BandSectionView(selectedSection: $selectedSection)
            .padding(.bottom)

        DiscographyView(discography: discography)
            .padding(.horizontal)
    }
}

struct BandView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BandView(bandUrlString: "https://www.metal-archives.com/bands/Death/141")
        }
        .environment(\.colorScheme, .dark)
        .environmentObject(Preferences())
    }
}
