//
//  UserSubmittedBandsView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 08/11/2022.
//

import SwiftUI

struct UserSubmittedBandsView: View {
    @EnvironmentObject private var preferences: Preferences
    @ObservedObject var viewModel: UserSubmittedBandsViewModel
    let onSelectBand: (String) -> Void

    var body: some View {
        ZStack {
            if let error = viewModel.error {
                VStack {
                    Text(error.userFacingMessage)
                    RetryButton(onRetry: viewModel.refresh)
                }
            } else if viewModel.manager.isLoading, viewModel.bands.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else if viewModel.bands.isEmpty {
                Text("No submitted bands")
                    .font(.callout.italic())
                    .frame(maxWidth: .infinity, alignment: .leading)
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
        LazyVStack {
            HStack {
                let entryCount = viewModel.manager.total
                if entryCount == 1 {
                    Text("1 band")
                } else {
                    Text("\(viewModel.manager.total) total bands")
                }
                Spacer()
                sortOptions
            }
            ForEach(viewModel.bands, id: \.hashValue) { band in
                UserSubmittedBandView(band: band)
                    .onTapGesture {
                        onSelectBand(band.band.thumbnailInfo.urlString)
                    }
                    .task {
                        if band == viewModel.bands.last {
                            await viewModel.getMoreBands(force: true)
                        }
                    }

                Divider()

                if band == viewModel.bands.last, viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .listStyle(.plain)
    }

    private var sortOptions: some View {
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
                viewModel.sortOption = .country(.ascending)
            }, label: {
                view(for: .country(.ascending))
            })

            Button(action: {
                viewModel.sortOption = .country(.descending)
            }, label: {
                view(for: .country(.descending))
            })

            Button(action: {
                viewModel.sortOption = .date(.ascending)
            }, label: {
                view(for: .date(.ascending))
            })

            Button(action: {
                viewModel.sortOption = .date(.descending)
            }, label: {
                view(for: .date(.descending))
            })
        }, label: {
            Text(viewModel.sortOption.title)
                .padding(8)
                .background(preferences.theme.primaryColor)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        })
        .transaction { transaction in
            transaction.animation = nil
        }
        .opacity(viewModel.bands.isEmpty ? 0 : 1)
        .disabled(viewModel.bands.isEmpty)
    }

    @ViewBuilder
    private func view(for option: UserSubmittedBandPageManager.SortOption) -> some View {
        if option == viewModel.sortOption {
            Label(option.title, systemImage: "checkmark")
        } else {
            Text(option.title)
        }
    }
}

private struct UserSubmittedBandView: View {
    @EnvironmentObject private var preferences: Preferences
    let band: UserSubmittedBand

    var body: some View {
        HStack {
            ThumbnailView(thumbnailInfo: band.band.thumbnailInfo, photoDescription: band.band.name)
                .font(.largeTitle)
                .foregroundColor(preferences.theme.secondaryColor)
                .frame(width: 64, height: 64)

            VStack(alignment: .leading) {
                Text(band.band.name)
                    .fontWeight(.bold)
                    .foregroundColor(preferences.theme.primaryColor)

                HStack {
                    Text(band.country.nameAndFlag)
                    Spacer()
                    Label(title: {
                        Text(band.date)
                    }, icon: {
                        Image(systemName: "calendar.badge.plus")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.blue, .primary)
                    })
                }

                Text(band.genre)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
}
