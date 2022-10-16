//
//  BandReadMoreView.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/07/2021.
//

import Combine
import SwiftUI

struct BandReadMoreView: View {
    @EnvironmentObject private var preferences: Preferences
    @StateObject private var viewModel: BandReadMoreViewModel
    @State private var showingSheet = false

    init(apiService: APIServiceProtocol, band: Band) {
        _viewModel = .init(wrappedValue: .init(apiService: apiService, band: band))
    }

    var body: some View {
        Group {
            switch viewModel.readMoreFetchable {
            case .error(let error):
                VStack(alignment: .center, spacing: 20) {
                    Text(error.userFacingMessage)
                        .frame(maxWidth: .infinity)
                        .font(.caption)

                    RetryButton(onRetry: viewModel.retry)
                }

            case .fetching:
                ProgressView()

            case .fetched(let readMore):
                Text(readMore)
                    .font(.callout)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(6)
                    .padding()
                    .onTapGesture {
                        showingSheet.toggle()
                    }
            }
        }
        .sheet(isPresented: $showingSheet) {
            if case .fetched(let readMore) = viewModel.readMoreFetchable {
                NavigationView {
                    ScrollView {
                        Text(readMore)
                            .padding()
                            .textSelection(.enabled)
                    }
                    .navigationTitle(viewModel.band.name)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                showingSheet.toggle()
                            }, label: {
                                Image(systemName: "xmark")
                            })
                        }
                    }
                }
                .tint(preferences.theme.primaryColor)
                .preferredColorScheme(.dark)
            }
        }
        .task {
            await viewModel.fetchReadMore()
        }
    }
}
