//
//  BandsByCountryView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 22/10/2022.
//

import SwiftUI

struct BandsByCountryView: View {
    @StateObject private var viewModel: BandsByCountryViewModel

    init(apiService: APIServiceProtocol, country: Country) {
        _viewModel = .init(wrappedValue: .init(apiService: apiService, country: country))
    }

    var body: some View {
        ZStack {
            if let error = viewModel.error {
                VStack {
                    Text(error.userFacingMessage)
                    RetryButton {
                        await viewModel.getMoreBands(force: true)
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
                    BandByCountryView(band: band)
                })
                .task {
                    if band == viewModel.bands.last {
                        await viewModel.getMoreBands(force: true)
                    }
                }

                if band == viewModel.bands.last, viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("\(viewModel.manager.total) bands in \(viewModel.country.nameAndFlag)")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { toolbarContent }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Menu(content: {
                Button(action: {
                    viewModel.sortOption = .band(.ascending)
                }, label: {
                    view(for: .band(.ascending))
                })

                Button(action: {
                    viewModel.sortOption = .band(.descending)
                }, label: {
                    view(for: .band(.descending))
                })

                Button(action: {
                    viewModel.sortOption = .genre(.ascending)
                }, label: {
                    view(for: .genre(.ascending))
                })

                Button(action: {
                    viewModel.sortOption = .genre(.descending)
                }, label: {
                    view(for: .genre(.descending))
                })

                Button(action: {
                    viewModel.sortOption = .location(.ascending)
                }, label: {
                    view(for: .location(.ascending))
                })

                Button(action: {
                    viewModel.sortOption = .location(.descending)
                }, label: {
                    view(for: .location(.descending))
                })
            }, label: {
                Text(viewModel.sortOption.title)
            })
            .transaction { transaction in
                transaction.animation = nil
            }
            .opacity(viewModel.bands.isEmpty ? 0 : 1)
            .disabled(viewModel.bands.isEmpty)
        }
    }

    @ViewBuilder
    private func view(for option: BandByCountryPageManager.SortOption) -> some View {
        if option == viewModel.sortOption {
            Label(option.title, systemImage: "checkmark")
        } else {
            Text(option.title)
        }
    }
}

private struct BandByCountryView: View {
    @EnvironmentObject private var preferences: Preferences
    let band: BandByCountry

    var body: some View {
        HStack {
            ThumbnailView(thumbnailInfo: band.band.thumbnailInfo,
                          photoDescription: band.band.name)
            .font(.largeTitle)
            .foregroundColor(preferences.theme.secondaryColor)
            .frame(width: 64, height: 64)

            VStack(alignment: .leading) {
                Text(band.band.name)
                    .fontWeight(.bold)
                    .foregroundColor(preferences.theme.primaryColor)

                if !band.location.isEmpty {
                    Text(band.location)
                }

                Text(band.status.rawValue)
                    .foregroundColor(band.status.color)

                Text(band.genre)
                    .font(.callout)
            }

            Spacer()
        }
    }
}
