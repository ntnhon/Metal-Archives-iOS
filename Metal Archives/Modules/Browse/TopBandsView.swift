//
//  TopBandsView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 17/10/2022.
//

import SwiftUI

struct TopBandsView: View {
    @StateObject private var viewModel: TopBandsViewModel

    init(apiService: APIServiceProtocol) {
        _viewModel = .init(wrappedValue: .init(apiService: apiService))
    }

    var body: some View {
        ZStack {
            switch viewModel.topBandsFetchable {
            case .fetching:
                HornCircularLoader()
            case .fetched:
                List {
                    ForEach(0..<viewModel.topBands.count, id: \.self) { index in
                        let topBand = viewModel.topBands[index]
                        NavigationLink(destination: {
                            BandView(apiService: viewModel.apiService,
                                     bandUrlString: topBand.band.thumbnailInfo.urlString)
                        }, label: {
                            TopBandView(topBand: topBand, index: index)
                        })
                    }
                }
                .listStyle(.plain)
            case .error(let error):
                HStack {
                    Text(error.userFacingMessage)
                    RetryButton {
                        await viewModel.fetchTopBands()
                    }
                }
            }
        }
        .navigationTitle("Top 100 bands")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .task {
            await viewModel.fetchTopBands()
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Menu(content: {
                ForEach(TopBandsCategory.allCases, id: \.self) { category in
                    Button(action: {
                        viewModel.category = category
                    }, label: {
                        if viewModel.category == category {
                            Label(category.description, systemImage: "checkmark")
                        } else {
                            Text(category.description)
                        }
                    })
                }
            }, label: {
                Text(viewModel.category.description)
            })
            .transaction { transaction in
                transaction.animation = nil
            }
            .opacity(viewModel.isFetched ? 1 : 0)
            .disabled(!viewModel.isFetched)
        }
    }
}

private struct TopBandView: View {
    @EnvironmentObject private var preferences: Preferences
    let topBand: TopBand
    let index: Int

    init(topBand: TopBand,
         index: Int) {
        self.topBand = topBand
        self.index = index
    }

    var body: some View {
        HStack {
            Text("\(index + 1). ")

            ThumbnailView(thumbnailInfo: topBand.band.thumbnailInfo,
                          photoDescription: topBand.band.name)
            .font(.largeTitle)
            .foregroundColor(preferences.theme.secondaryColor)
            .frame(width: 64, height: 64)

            VStack(alignment: .leading) {
                Text(topBand.band.name)
                    .fontWeight(.bold)
                    .foregroundColor(preferences.theme.primaryColor)
            }
            .padding(.vertical)

            Spacer()

            Text("\(topBand.count)")
        }
        .contentShape(Rectangle())
    }
}
