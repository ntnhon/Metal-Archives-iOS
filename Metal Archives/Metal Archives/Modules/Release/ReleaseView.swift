//
//  ReleaseView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 30/07/2022.
//

import SwiftUI

struct ReleaseView: View {
    @StateObject private var viewModel: ReleaseViewModel

    init(apiService: APIServiceProtocol,
         releaseUrlString: String) {
        let vm = ReleaseViewModel(apiService: apiService,
                                  releaseUrlString: releaseUrlString)
        _viewModel = .init(wrappedValue: vm)
    }

    var body: some View {
        ZStack {
            switch viewModel.releaseFetchable {
            case .waiting:
                EmptyView()
            case .fetching:
                ProgressView()
            case .fetched(let release):
                Text(release.title)
            case .error(let error):
                VStack {
                    Text(error.userFacingMessage)
                    RetryButton(onRetry: {
                        Task {
                            await viewModel.fetchRelease()
                        }
                    })
                }
            }
        }
        .task {
            await viewModel.fetchRelease()
        }
    }
}

struct ReleaseView_Previews: PreviewProvider {
    static var previews: some View {
        ReleaseView(apiService: APIService(),
                    releaseUrlString: "https://www.metal-archives.com/albums/Death/Human/606")
    }
}
