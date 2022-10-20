//
//  BandsByAlphabetView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 20/10/2022.
//

import SwiftUI

struct BandsByAlphabetView: View {
    @StateObject private var viewModel: BandsByAlphabetViewModel

    init(apiService: APIServiceProtocol, letter: Letter) {
        _viewModel = .init(wrappedValue: .init(apiService: apiService, letter: letter))
    }

    var body: some View {
        ZStack {
            if let error = viewModel.error {
                VStack {
                    Text(error.userFacingMessage)
                    RetryButton {
                        Task {
                            await viewModel.getMoreBands(force: true)
                        }
                    }
                }
            } else if viewModel.isLoading && viewModel.bands.isEmpty {
                ProgressView()
            } else if viewModel.bands.isEmpty {
                Text("No bands found")
                    .font(.callout.italic())
            } else {
                bandList
            }
        }
        .task {
            await viewModel.getMoreBands(force: false)
        }
    }

    @ViewBuilder
    private var bandList: some View {
        List {
            ForEach(viewModel.bands, id: \.band.thumbnailInfo.urlString) { band in
                NavigationLink(destination: {
                    BandView(apiService: viewModel.apiService,
                             bandUrlString: band.band.thumbnailInfo.urlString)
                }, label: {
                    BandByAlphabetView(band: band)
                })
                .task {
                    if band == viewModel.bands.last {
                        await viewModel.getMoreBands(force: true)
                    }
                }
            }

            if viewModel.isLoading && !viewModel.bands.isEmpty {
                ProgressView()
            }
        }
        .listStyle(.plain)
        .navigationTitle("\(viewModel.manager.total) bands by \"\(viewModel.letter.description)\"")
        .navigationBarTitleDisplayMode(.large)
    }
}

private struct BandByAlphabetView: View {
    let band: BandByAlphabet

    var body: some View {
        Text(band.band.name)
    }
}
