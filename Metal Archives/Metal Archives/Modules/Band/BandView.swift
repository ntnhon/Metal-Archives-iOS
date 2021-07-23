//
//  BandView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 26/06/2021.
//

import SwiftUI

// swiftlint:disable let_var_whitespace
struct BandView: View {
    @EnvironmentObject private var preferences: Preferences
    @StateObject private var viewModel: BandViewModel
    @State private var selectedSection: BandSection = .discography
    @State private var bottomPadding: CGFloat = 0
    @State private var showSearch = false

    init(bandUrlString: String) {
        self._viewModel = StateObject(wrappedValue: .init(bandUrlString: bandUrlString))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationLink(destination: SearchView(), isActive: $showSearch) {
                EmptyView()
            }

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
                }
                .padding(.bottom, bottomPadding)
            }
            switch viewModel.bandAndDiscographyFetchable {
            case .fetched: bottomToolbar
            default: EmptyView()
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
        .onAppear {
            viewModel.fetchBandAndDiscography()
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

        DiscographyView(discography: discography, releaseYearOrder: preferences.dateOrder)
            .padding(.horizontal)
    }

    @ViewBuilder
    private var bottomToolbar: some View {
        let bottomInset = UIApplication.shared.windows.first { $0.isKeyWindow }?.safeAreaInsets.bottom ?? 0
        VStack(spacing: 0) {
            Color(.separator)
                .frame(height: 0.5)
                .opacity(0.5)
            toolbarButtons
                .padding(.horizontal)
                .modifier(SizeModifier())
                .onPreferenceChange(SizePreferenceKey.self) {
                    bottomPadding = $0.height + bottomInset + 10
                }
            Spacer()
                .frame(height: bottomInset)
        }
        .background(Blur())
    }

    private var toolbarButtons: some View {
        HStack {
            actionButton(imageSystemName: "star") {
                print("star")
            }

            Spacer()

            actionButton(imageSystemName: "house") {
                ApplicationUtils.popToRootView()
            }

            Spacer()

            actionButton(imageSystemName: "magnifyingglass.circle") {
                showSearch = true
            }

            Spacer()

            actionButton(imageSystemName: "play") {
                print("play")
            }

            Spacer()

            actionButton(imageSystemName: "square.and.arrow.up") {
                switch viewModel.bandAndDiscographyFetchable {
                case .fetched(let (band, _)): ApplicationUtils.share(urlString: band.urlString)
                default: break
                }
            }
        }
        .font(.title2)
    }

    private func actionButton(imageSystemName: String,
                              action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: imageSystemName)
                .padding(.horizontal)
                .padding(.vertical, 10)
        }
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
