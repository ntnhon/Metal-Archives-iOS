//
//  ReleaseView.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 30/07/2022.
//

import SwiftUI

struct ReleaseView: View {
    @StateObject private var viewModel: ReleaseViewModel
    private let apiService: APIServiceProtocol

    init(apiService: APIServiceProtocol,
         releaseUrlString: String) {
        self.apiService = apiService
        let vm = ReleaseViewModel(apiService: apiService,
                                  releaseUrlString: releaseUrlString)
        _viewModel = .init(wrappedValue: vm)
    }

    var body: some View {
        ZStack {
            switch viewModel.releaseFetchable {
            case .fetching, .waiting:
                HornCircularLoader()
            case .fetched(let release):
                ReleaseContentView(apiService: apiService,
                                   release: release)
                .environmentObject(viewModel)
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

private struct ReleaseContentView: View {
    @EnvironmentObject private var preferences: Preferences
    @EnvironmentObject private var viewModel: ReleaseViewModel
    @Environment(\.selectedPhoto) private var selectedPhoto
    @State private var titleViewAlpha = 0.0
    @State private var topSectionSize: CGSize = .zero
    let apiService: APIServiceProtocol
    let release: Release

    var body: some View {
        OffsetAwareScrollView(
            axes: .vertical,
            showsIndicator: true,
            onOffsetChanged: { point in
                let screenBounds = UIScreen.main.bounds
                if point.y < 0,
                   abs(point.y) > (min(screenBounds.width, screenBounds.height) * 2 / 3) {
                    titleViewAlpha = abs(point.y) / min(screenBounds.width, screenBounds.height)
                } else {
                    titleViewAlpha = 0.0
                }
            },
            content: {
                Text(release.title)
            })
        .toolbar { toolbarContent }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Group {
                switch viewModel.coverFetchable {
                case .fetched(let image):
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50)
                    }
                default:
                    EmptyView()
                }
            }
//            .opacity(titleViewAlpha)
        }

        ToolbarItem(placement: .principal) {
            Text(release.title)
                .font(.title2)
                .fontWeight(.bold)
                .textSelection(.enabled)
                .minimumScaleFactor(0.5)
            //            .opacity(titleViewAlpha)
        }
    }
}

struct ReleaseView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ReleaseView(apiService: APIService(),
                        releaseUrlString: "https://www.metal-archives.com/albums/Death/Human/606")
        }
        .environment(\.colorScheme, .dark)
        .environmentObject(Preferences())
    }
}
